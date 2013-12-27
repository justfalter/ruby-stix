require 'spec_helper'

include StixRuby::Aliases

describe Java::OrgMitreStixCore::STIXType do
  before do
    @stix = STIXPackage.new
  end

  it "should have a default version" do
    @stix.version.should == "1.0.1"
  end

  it "should allow adding observables" do
    @stix.add_observable(Observable.new)
    @stix.observables.observables.length.should == 1
  end

  it "should allow adding campaigns" do
    @stix.add_campaign(Campaign.new)
    @stix.campaigns.campaigns.length.should == 1
  end

  it "should allow adding courses of action" do
    @stix.add_course_of_action(CourseOfAction.new)
    @stix.courses_of_action.course_of_actions.length.should == 1
  end

  it "should allow adding exploit targets" do
    @stix.add_exploit_target(ExploitTarget.new)
    @stix.exploit_targets.exploit_targets.length.should == 1
  end

  it "should allow adding incidents" do
    @stix.add_incident(Incident.new)
    @stix.incidents.incidents.length.should == 1
  end

  it "should allow adding indicators" do
    @stix.add_indicator(Indicator.new)
    @stix.indicators.indicators.length.should == 1
  end

  it "should allow adding threat actors" do
    @stix.add_threat_actor(ThreatActor.new)
    @stix.threat_actors.threat_actors.length.should == 1
  end

  it "should allow adding TTPs" do
    @stix.add_ttp(TTP.new)
    @stix.ttps.ttps.length.should == 1
  end

end