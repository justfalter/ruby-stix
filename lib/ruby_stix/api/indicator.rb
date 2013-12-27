class Java::OrgMitreStixIndicator::IndicatorType
  def item=(val)
    if val.kind_of?(org.mitre.cybox.core.ObservableType)
      self.observable = val
    elsif val.kind_of?(org.mitre.cybox.core.ObjectType)
      self.observable = org.mitre.cybox.core.ObservableType.new(:object => val)
    elsif val.kind_of?(org.mitre.cybox.core.EventType)
      self.observable = org.mitre.cybox.core.ObservableType.new(:event => val)
    elsif val.kind_of?(org.mitre.cybox.common.ObjectPropertiesType)
      self.observable = org.mitre.cybox.core.ObservableType.new(:object => org.mitre.cybox.core.ObjectType.new(:properties => val))
    elsif val.kind_of?(Hash) && val[:operator]
      self.composite_indicator_expression = process_composition(val)
    else
      raise "Unknown item type: #{val.class}"
    end
  end

  def process_composition(composition_hash)
    operator = org.mitre.stix.indicator.OperatorTypeEnum.from_value(composition_hash[:operator].to_s.upcase)
    composition = org.mitre.stix.indicator.CompositeIndicatorExpressionType.new(:operator => operator)
    composition_hash[:items].each do |item|
      indicator = item.kind_of?(org.mitre.stix.common.IndicatorBaseType) ? item : self.class.new(:item => item)
      composition.add_indicator(indicator)
    end

    return composition
  end
end