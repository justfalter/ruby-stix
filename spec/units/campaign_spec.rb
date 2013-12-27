require 'spec_helper'

describe "Campaign" do
  before do
    @campaign = org.mitre.stix.campaign.CampaignType.new
  end

  it "should be able to add attribution" do
    @campaign.add_attribution([{:threat_actor => org.mitre.stix.ta.ThreatActorType.new}])
  end

  it "should be able to add associated campaigns" do
    @campaign.add_associated_campaign({:campaign => org.mitre.stix.campaign.CampaignType.new})
  end
end