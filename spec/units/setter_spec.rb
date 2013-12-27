require 'spec_helper'

describe "The setter helper" do
  before do
    @package = org.mitre.stix.core.STIXType.new
  end

  it "should allow assignments by hash" do
    @package.stix_header = {:title => "Testing"}
    @package.stix_header.title.should == "Testing"

    @package.stix_header = org.mitre.stix.core.STIXHeaderType.new(:title => "Testing")
    @package.stix_header.title.should == "Testing"
  end

  it "should raise an error when passing hashes with invalid values" do
    expect { @package.stix_header = {:something => "blah"} }.to raise_error
  end

  it "should work with Java names" do
    @package.setSTIXHeader(:title => "Testing")
    @package.stix_header.title.should == "Testing"
  end

  it "should allow assigning values automatically" do
    header = org.mitre.stix.core.STIXHeaderType.new
    header.package_intent = "Indicators"

    header.package_intent.value.should == "Indicators"
    # TODO: Is there a good way of automatically using the default vocabs? Probably
    # would need to manually list them somewhere, but maybe it could be DSLed rather
    # than code
  end

  it "should allow assign generic array lists automatically" do
    is = org.mitre.stix.common.InformationSourceType.new({
      :tools => [
        {
          :name => "Calamine",
          :description => "COA_DESCRIPTION"
        }
      ]
    })
  end

  it "should allow adding autocreatable values to list" do
    campaign = org.mitre.stix.campaign.CampaignType.new

    campaign.add_attribution([:threat_actor => {:idref => '1234'}])
    campaign.attributions.first.should be_kind_of(org.mitre.stix.campaign.AttributionType)
  end
end