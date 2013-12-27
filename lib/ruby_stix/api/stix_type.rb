class Java::OrgMitreStixCore::STIXType
  include StixRuby::DocumentWriter

  def add_observable(observable)
    self.observables ||= org.mitre.cybox.core.ObservablesType.new(:cybox_major_version => '2', :cybox_minor_version => '0')
    self.observables.add_observable(observable)
  end

  def add_campaign(campaign)
    self.campaigns ||= org.mitre.stix.core.CampaignsType.new
    self.campaigns.add_campaign(campaign)
  end

  def add_course_of_action(coa)
    self.courses_of_action ||= org.mitre.stix.core.CoursesOfActionType.new
    self.courses_of_action.course_of_actions.add(coa)
  end

  def add_exploit_target(et)
    self.exploit_targets ||= org.mitre.stix.common.ExploitTargetsType.new
    self.exploit_targets.add_exploit_target(et)
  end

  def add_incident(incident)
    self.incidents ||= org.mitre.stix.core.IncidentsType.new
    self.incidents.add_incident(incident)
  end

  def add_indicator(indicator)
    self.indicators ||= org.mitre.stix.core.IndicatorsType.new
    self.indicators.add_indicator(indicator)
  end

  def add_threat_actor(ta)
    self.threat_actors ||= org.mitre.stix.core.ThreatActorsType.new
    self.threat_actors.add_threat_actor(ta)
  end

  def ttps
    self.getTTPs
  end

  def ttps=(val)
    self.setTTPs(val)
  end

  def add_ttp(ttp)
    self.ttps ||= org.mitre.stix.core.TTPsType.new
    self.ttps.getTTPS.add(ttp)
  end

  def process_args(args)
    args[:version] ||= "1.0.1"
    args
  end
end