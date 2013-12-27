class Java::OrgMitreCyboxCore::ObservableType
  def item=(val)
    if val.kind_of?(org.mitre.cybox.core.ObjectType)
      self.object = val
    elsif val.kind_of?(org.mitre.cybox.core.EventType)
      self.event = val
    elsif val.kind_of?(org.mitre.cybox.common.ObjectPropertiesType)
      self.object = Java::OrgMitreCyboxCore::ObjectType.new(:properties => val)
    elsif val.kind_of?(Hash) && val[:operator]
      self.observable_composition = process_composition(val)
    else
      raise "Unknown item type: #{val.class}"
    end
  end

  def process_composition(composition_hash)
    operator = org.mitre.cybox.core.OperatorTypeEnum.from_value(composition_hash[:operator].to_s.upcase)
    composition = Java::OrgMitreCyboxCore::ObservableCompositionType.new(:operator => operator)
    composition_hash[:items].each do |item|
      observable = item.kind_of?(org.mitre.cybox.core.ObservableType) ? item : self.class.new(:item => item)
      composition.add_observable(observable)
    end

    return composition
  end
end