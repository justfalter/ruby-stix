require 'spec_helper'

describe Java::OrgMitreCyboxCore::ObjectType do
  context ".add_related_object" do

    before do
      @object = org.mitre.cybox.core.ObjectType.new
    end

    it "should add an actual related object (of type RelatedObjectType)" do
      related_object = org.mitre.cybox.core.RelatedObjectType.new
      @object.add_related_object(related_object)
      @object.related_objects.related_objects.first.should == related_object
    end

    it "should add a normal object (creating the Related_Object)" do
      object = org.mitre.cybox.core.ObjectType.new
      @object.add_related_object(object)
      @object.related_objects.related_objects.first.idref == object.id
    end

    it "should match the vocabulary for relationship" do
      object = org.mitre.cybox.core.ObjectType.new
      @object.add_related_object(object, 'Child_Of')
      @object.related_objects.related_objects.first.relationship.class.should == org.mitre.cybox.vocabularies.ObjectRelationshipVocab10
      @object.related_objects.related_objects.first.relationship.value.should == "Child_Of"
    end

    it "should allow setting arbitrary values" do
      object = org.mitre.cybox.core.ObjectType.new
      @object.add_related_object(object, 'Nonsense')
      @object.related_objects.related_objects.first.relationship.class.should == org.mitre.cybox.common.ControlledVocabularyStringType
      @object.related_objects.related_objects.first.relationship.value.should == "Nonsense"
    end

  end
end