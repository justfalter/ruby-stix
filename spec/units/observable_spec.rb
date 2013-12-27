require 'spec_helper' 

describe Java::OrgMitreCyboxCore::ObservableType do

  context ".item=" do

    before do
      @observable = org.mitre.cybox.core.ObservableType.new
    end

    it "should allow assigning an object or event" do
      object = org.mitre.cybox.core.ObjectType.new
      @observable.item = object
      @observable.object.should == object

      event = org.mitre.cybox.core.EventType.new
      @observable.item = event
      @observable.event.should == event
    end

    it "should allow assigning properties" do
      properties = org.mitre.cybox.objects.file.FileObjectType.new
      @observable.item = properties
      @observable.object.properties.should == properties
    end

    it "should accept a composition hash" do
      file = org.mitre.cybox.objects.file.FileObjectType.new
      observable = org.mitre.cybox.core.ObservableType.new
      @observable.item = {:operator => "OR", :items => [file, observable]}

      @observable.observable_composition.observables[0].object.properties.should == file
      @observable.observable_composition.observables[1].should == observable
      @observable.observable_composition.operator.should == org.mitre.cybox.core.OperatorTypeEnum::OR
    end
  end

end