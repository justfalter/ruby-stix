require 'spec_helper'

describe "Namespace cleaning" do

  it "should remove unnecessary namespaces" do
    doc = org.mitre.stix.core.STIXType.new
    doc.indicators = org.mitre.stix.core.IndicatorsType.new
    doc.indicators.add_indicator(org.mitre.stix.indicator.IndicatorType.new)

    doc.to_s.length.should == 471 # A hacky way of checking to make sure the namespaces were removed
  end

  it "should not remove the ID namespace prefix" do
    StixRuby.set_id_namespace("example.com", "example")
    doc = org.mitre.stix.core.STIXType.new
    doc.indicators = org.mitre.stix.core.IndicatorsType.new
    doc.indicators.add_indicator(org.mitre.stix.indicator.IndicatorType.new)

    doc.to_s.length.should == 515
  end
end