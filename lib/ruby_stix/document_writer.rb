require 'stringio'

module StixRuby::DocumentWriter

  def self.included(parent)
    parent.send(:include, StixRuby::DocumentWriter::InstanceMethods)
    parent.send(:extend, StixRuby::DocumentWriter::ClassMethods)
  end

  module InstanceMethods
    def write(io, args = {})
      clean_namespaces = args[:clean_namespaces] != false

      if clean_namespaces
        document = self.class.new_dom
        self.class.marshaller.marshal(self, document)

        namespaces = {}
        namespaces[StixRuby::NAMESPACE_MAPPINGS[document.document_element.namespace_uri]] = true
        for i in 0...document.document_element.child_nodes.length
          collect_namespaces(document.document_element.child_nodes.item(i), namespaces, )
        end

        to_delete = []

        for i in 0...document.document_element.attributes.length
          attribute = document.document_element.attributes.item(i)
          if attribute.name =~ /xmlns/
            if !(namespaces[attribute.name.split(':').last] || namespaces[attribute.value])
              to_delete.push(attribute.name)
            end
          end
        end

        to_delete.each {|i| document.document_element.remove_attribute(i)}
        io = to_java_io(io)

        self.class.dom_writer.set_output_property(javax.xml.transform.OutputKeys::INDENT, args[:no_formatting] == true ? 'no' : 'yes');
        self.class.dom_writer.transform(javax.xml.transform.dom.DOMSource.new(document), javax.xml.transform.stream.StreamResult.new(io))
      else
        io = to_java_io(io)
        self.class.marshaller.set_property(javax.xml.bind.Marshaller.JAXB_FORMATTED_OUTPUT, !(args[:no_formatting] == true))
        self.class.marshaller.marshal(self, io)
      end
      
      return io
    end

    def to_java_io(io)
      if io.kind_of?(StringIO) || io.kind_of?(File)
        io.to_outputstream
      else
        io
      end
    end

    def to_s
      io = StringIO.new
      write(io)
      io.string
    end

    private

    def collect_namespaces(node, coll)
      coll[node.namespace_uri] = true
      for i in 0...node.child_nodes.length
        collect_namespaces(node.child_nodes.item(i), coll)
      end

      attributes = node.get_attributes || []
      for i in 0...attributes.length
        attribute = node.get_attributes.item(i)
        coll[attribute.namespace_uri] = true

        if attribute.namespace_uri == 'http://www.w3.org/2001/XMLSchema-instance' && attribute.value =~ /:/
          coll[attribute.value.split(':').first] = true
        elsif attribute.local_name == 'id' || attribute.local_name == 'idref'
          coll[attribute.value.split(':').first] = true
        end
      end
      coll
    end
  end

  module ClassMethods

    def dom_writer
      if @transformer.nil?
        factory = javax.xml.transform.TransformerFactory.new_instance
        @transformer = factory.new_transformer
        @transformer.set_output_property("{http://xml.apache.org/xslt}indent-amount", "4")
      end
      return @transformer
    end

    def jaxb_context
      @context ||= javax.xml.bind.JAXBContext.new_instance(org.mitre.stix.core.STIXType.java_class)
    end

    def marshaller
      if @marshaller.nil?
        @marshaller = jaxb_context.create_marshaller
        marshaller.set_property("com.sun.xml.internal.bind.namespacePrefixMapper", StixRuby::DocumentWriter::StixNamespaceMapper.new);
      end

      return @marshaller
    end

    def new_dom
      if @document_builder.nil?
        dbf = javax.xml.parsers.DocumentBuilderFactory.new_instance
        dbf.namespace_aware = true
        @document_builder = dbf.new_document_builder
      end
      @document_builder.new_document
    end
  end

  class StixNamespaceMapper < com.sun.xml.internal.bind.marshaller.NamespacePrefixMapper
    def initialize(mappings = {})
      super()
      @mappings = mappings
    end

    def getPreferredPrefix(uri, suggestion, require_prefix)
      if @mappings[uri]
        @mappings[uri]
      elsif uri == StixRuby.id_namespace_uri
        return StixRuby.id_namespace_prefix
      elsif StixRuby::NAMESPACE_MAPPINGS[uri]
        return StixRuby::NAMESPACE_MAPPINGS[uri]
      else
        return suggestion
      end
    end

    def getPreDeclaredNamespaceUris
      StixRuby::NAMESPACE_MAPPINGS.keys + [StixRuby.id_namespace_uri, ''].compact + @mappings.keys
    end

  end
end