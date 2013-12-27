class Java::OrgMitreCyboxCore::ObjectType
  def add_related_object(object, relationship = nil)
    self.related_objects ||= org.mitre.cybox.core.RelatedObjectsType.new

    if object.kind_of?(org.mitre.cybox.core.RelatedObjectType)
      self.related_objects.add_related_object(object)
    else
      related_object = org.mitre.cybox.core.RelatedObjectType.new(:idref => object.id)
      if relationship
        if relationship.kind_of?(String)
          # Ugh, why does Java throw an exception here?
          begin
            enum = org.mitre.cybox.vocabularies.ObjectRelationshipEnum10.from_value(relationship)
            related_object.relationship = org.mitre.cybox.vocabularies.ObjectRelationshipVocab10.new(:value => enum.value)
          rescue
            related_object.relationship = org.mitre.cybox.common.ControlledVocabularyStringType.new(:value => relationship)
          end
        else
          related_object.relationship = relationship
        end
      end

      self.related_objects.add_related_object(related_object)
    end
  end
end