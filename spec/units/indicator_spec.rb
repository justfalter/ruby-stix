require 'spec_helper' 

describe Java::OrgMitreStixIndicator::IndicatorType do

  context ".item=" do

    before do
      @indicator = org.mitre.stix.indicator.IndicatorType.new
    end

    it "should allow assigning an observable" do
      observable = org.mitre.cybox.core.ObservableType.new
      @indicator.item = observable
      @indicator.observable.should == observable
    end

    it "should allow assigning an object or event" do
      object = org.mitre.cybox.core.ObjectType.new
      @indicator.item = object
      @indicator.observable.object.should == object

      event = org.mitre.cybox.core.EventType.new
      @indicator.item = event
      @indicator.observable.event.should == event
    end

    it "should allow assigning properties" do
      properties = org.mitre.cybox.objects.file.FileObjectType.new
      @indicator.item = properties
      @indicator.observable.object.properties.should == properties
    end

    it "should accept a composition hash" do
      file = org.mitre.cybox.objects.file.FileObjectType.new
      indicator = org.mitre.stix.indicator.IndicatorType.new
      @indicator.item = {:operator => "OR", :items => [file, indicator]}

      @indicator.composite_indicator_expression.indicators[0].observable.object.properties.should == file
      @indicator.composite_indicator_expression.indicators[1].should == indicator
      @indicator.composite_indicator_expression.operator.should == org.mitre.stix.indicator.OperatorTypeEnum::OR
    end
  end

end