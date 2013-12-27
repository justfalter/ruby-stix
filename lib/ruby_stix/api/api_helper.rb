require 'active_support/inflector'
require 'set'

java_import 'javax.xml.datatype.DatatypeFactory'

ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym 'TTP'
  inflect.acronym 'TTPs'
end

class Java::OrgMitre::ApiHelper

  BLACKLIST = ["getClass", "hashCode", "equals", "toString", "notify", "notifyAll", "wait"]
  
  def initialize(*args)
    # Every time we create an object, we try to annotate that object's class. If the class has been annotated already,
    # this does nothing.
    annotate_class!

    # Call the super constructor to create the java object backing
    super()

    # We add several options for creating new objects. This method figures out what the particular object we're creating
    # supports and then processes the arguments. It will throw an error if invalid arguments are passed.
    process_constructor_args(*args)

    # (TODO: This may not be the right place to put this?)
    # Generate an ID if the object supports it and we didn't set something manually
    self.generate_id! if should_create_id?
  end

  # Returns whether or not a new object should have an auto-generated ID. The criteria are:
  # 1. It responds to "id" and "idref" (i.e. is a STIX-idable object)
  # 2. It doesn't have "suppress_id" set
  # 3. There's no id or idref set already
  def should_create_id?
    self.respond_to?(:id) && self.respond_to?(:idref) && !self.class.suppress_id? && self.idref.nil? && self.id.nil?
  end

  # Process arguments that are passed to the constructor
  # There are a couple options here:

  # 1. A hash is passed, which will call appropriate setter methods to set each value to the key
  # 2. A string is passed, which will set the string value of the element
  # 3. A string and hash are passed, which will do both
  # 4. Nothing is passed, which will just create the object
  def process_constructor_args(*args)
    # If two arguments are passed, option #3 is the winner. The first argument will set the value and the second argument is the kv hash
    if args.length == 2 && self.respond_to?("value=")
      self.value = args[0]
      args = args[1]
    # If one argument is passed and it's not a hash, try to set it as the value (likely it's a string) and use an empty hash as the kv hash
    elsif args.length == 1 && !args[0].kind_of?(Hash) && self.respond_to?("value=")
      self.value = args[0]
      args = {}
    # If one argument is passed and it's a hash, use that as the kv hash
    elsif args.length == 1 && args[0].kind_of?(Hash)
      args = args[0]
    # If nothing was passed, use an empty hash as the kv hash
    elsif args.length == 0
      args = {}
    elsif args.first.kind_of?(Array)
      handle_array_argument(self, args.first)
      args = {}
    # Finally, throw an error if the arguments are anything else
    else
      raise "Invalid arguments to construct #{self.class.to_s}: #{args.inspect}"
    end

    # If key/value pairs were passed, use them
    process_args(args).each do |key, value|
      process_single_argument(key, value)
    end
  end

  def process_single_argument(k, v)
    # If we respond to the setter, call it. This effectively allows Java-style keyword argument names to be used
    if self.respond_to?("set#{k}")
      self.send("set#{k}", v)
    # If we respond to the Ruby setter, call it. This allows Ruby-style keyword argument names to be used
    elsif self.respond_to?("#{k}=")
      self.send("#{k}=", v)
    # If the value is an array, we can handle it a little differently
    # Note that some array arguments might get caught by the setter
    elsif v.kind_of?(Array)
      # Find the Java method name even if we used a Ruby-style name. This is imperfect so may throw errors.
      java_method_name = java_method_name_for_key(k)

      expected_type = nil

      # Add each value individually to the list
      v.each do |value|
        argument_type = find_generic_argument_for(java_method_name)

        value = auto_create_object(argument_type, value)

        # Finally, set the value
        self.send(java_method_name).add(value)
      end
    else
      raise ArgumentError.new("Invalid argument to construct #{self.class.to_s}: `#{k}`")
    end
  end

  def java_method_name_for_key(k)
    if self.respond_to?("get#{k}")
      "get#{k}"
    elsif self.respond_to?("get#{to_java_name(k)}")
      "get#{to_java_name(k)}"
    else
      raise "Unable to find corresponding java method for #{k}"
    end
  end

  # Finds the expected class for a list by parsing it out of the Java signature. This kind of blows but the way Java
  # implements generics (type erasure) means the JRuby code does not have access to the generic type.
  def find_generic_argument_for(k)
    return eval(self.java_class.java_method(k).to_generic_string.match(/<(.+)>/)[1])
  end

  # Convert a Ruby-style method name (lower snake) to a Java-style method name (camel)
  # This is imperfect, really I would like to re-use the JRuby logic but don't know how.
  def to_java_name(string)
    string.to_s.camelize
  end

  # Generate a random ID. Uses the ID namespace if it's been set.
  def generate_id!
    self.id = StixRuby.generate_id(self.class.to_s.split('::').last.gsub('Type', '').downcase)
  end

  # Theoretically method_missing might be used for more, but currently it just tries to catch "add_"
  # calls and direct them to the appropriate child.
  # TODO: Should we just define these methods manually by iterating over all methods and finding lists?
  def method_missing(method_name, *args)
    # Catch us trying to "add_observable" to "ObservablesType" and correctly handle it
    if matches = method_name.to_s.match(/^add_(.+)$/)
      if matches[1] && self.respond_to?(matches[1].pluralize)
        java_method_name = java_method_name_for_key(matches[1].pluralize)
        if respond_to?(java_method_name)
          # If the method is a list, try to add the object
          if send(java_method_name).class == Java::JavaUtil::ArrayList # Need to do an equality check on the class because sometimes other classes masquerade as lists
            argument_type = find_generic_argument_for(java_method_name)
            self.send(java_method_name).add(auto_create_object(argument_type, args.first))
          elsif send(java_method_name).nil?
            # Use the setter...
            send(java_method_name.gsub(/^get/, "set"), args)
          else
            # We already have an item in the list, so just add the new one
            intermediate = send(java_method_name)
            argument_type = intermediate.find_generic_argument_for(java_method_name)
            intermediate.send(java_method_name).add(auto_create_object(argument_type, args.first))            
          end
        else
          super
        end
      else
        super
      end
    else
      super
    end
  end

  # This is a callback that children can override to add fancy helpers to constructor arguments
  # Here though it's a pass-through
  def process_args(args)
    args
  end

  # Some behavior to determine whether to generate an ID
  def self.suppress_id
    @suppress_id = true
  end

  # TODO: This would be better without the multiple checks...
  def self.suppress_id?
    @suppress_id == true || (superclass.respond_to?(:suppress_id) && superclass.suppress_id?)
  end

  def self.annotate!
    # Mark us as annotated
    @annotated = true

    # Annotate superclass if it's ok with that
    self.superclass.annotate! if self.superclass.respond_to?(:annotate!)

    # JRuby->Ruby name translation is not perfect and, for example, screws up "TTP"
    # This will go through all methods and correct the ruby methods
    StixRuby::IRREGULARS.each do |irregular_pattern, correct_pattern|
      self.instance_methods.select {|m| m.to_s =~ irregular_pattern}.each do |irregular|
        alias_method irregular.to_s.gsub(irregular_pattern, correct_pattern), irregular
      end
    end

    # Hooks into both Ruby and Java-style setters and makes them a little more intelligent by trying
    # to handle arrays appropriately and call constructors automatically when necessary
    self.setter_methods.each do |method_name, java_method|
      # Find the type of the argument and the name of the method
      argument_type = java_method.argument_types.first.ruby_class 

      # Do not annotate this method if it's already annotated or has a basic value constructor
      next if argument_type == Java::JavaLang::Object || self.annotated_method?(method_name)

      # Mark this method as annotated
      self.annotated_method(method_name)

      # Alias the raw version
      alias_method method_name + "Raw", method_name

      # Re-define the method
      define_method method_name, ->(*args) do
        # Must have at least one argument
        raise ArgumentError.new("Wrong number of arguments (0 for 1)") if args.nil? || args.length == 0

        # Pass the argument to the raw setter if it's already of the correct type
        if args.first.kind_of?(argument_type)
          send(method_name + "Raw", *args)
        # This handles cases where we have essentially a wrapper element around an array
        # and allows us to just set the array
        elsif args.first.kind_of?(Array)
          new_obj = argument_type.new
          handle_array_argument(new_obj, args.first)
          send(method_name + "Raw", new_obj)
        else
          # Try to auto-create the object (magic happens here)
          object = auto_create_object(argument_type, args.first)

          send(method_name + "Raw", object)
        end          
      end
    end
  end

  # Returns the Ruby or Java setter method name and the corresponding java setter method reference
  def self.setter_methods
    self.java_class.java_instance_methods.select {|method| method.name =~ /^set/ && !(method.name =~ /Raw$/)}.map { |method|
      # If the method accepts more than one argument, ignore it
      if method.argument_types.length == 1
        methods = [[method.name, method]]
        methods << [ruby_name(method.name), method] if self.instance_methods.find {|m| m.to_s == ruby_name(method.name)}
        ruby_setter = ruby_name(method.name.gsub("set", "") + "=")
        methods << [ruby_setter, method] if self.instance_methods.find {|m| m.to_s == ruby_setter}
        methods
      else
        nil
      end
    }.compact.flatten(1)
  end

  def handle_array_argument(assign_to, argument)
    # Create the array destination
    # Try to find the appropriate getter method for the array
    getter = assign_to.java_class.java_instance_methods.reject {|m| BLACKLIST.include?(m.name) || m.return_type != java.util.List.java_class }
    raise "Unable to automatically determine array container, please explicitly specify it" if getter.length != 1
    getter = getter.first.name
    array = assign_to.send(getter)
    getter_reference = assign_to.java_class.java_method(getter).to_generic_string.match(/<(.+)>/)[1]
    expected_type = eval(getter_reference)
    argument.each {|item|
      array.add(auto_create_object(expected_type, item))
    }
  end

  def auto_create_object(argument_type, arg)
    if arg.kind_of?(argument_type)
      arg
    elsif argument_type.respond_to?(:from_value)
      argument_type.from_value(arg)
    # Handle an array argument
    # JAXB dates are really F'd up, so autoconvert them
    elsif argument_type == javax.xml.datatype.XMLGregorianCalendar
      calendar = java.util.GregorianCalendar.new
      calendar.setTime(arg.to_java)
      DatatypeFactory.newInstance.newXMLGregorianCalendar(calendar)
    else
      argument_type.new(arg)
    end
  end

  def self.ruby_name(method)
    method.underscore
  end

  # A bunch of crap for detecting when things have already been annotated
  def self.annotated?
    @annotated == true
  end

  def annotated?
    self.class.annotated?
  end

  def self.annotated_method?(name)
    @annotated_methods ||= Set.new
    @annotated_methods.include?(name) || (self.superclass.respond_to?(:annotated_method?) && self.superclass.annotated_method?(name))
  end

  def self.annotated_method(method)
    @annotated_methods ||= Set.new
    @annotated_methods.add(method)
  end

  def annotate_class!
    self.class.annotate! unless annotated?
  end
end