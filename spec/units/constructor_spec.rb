require 'spec_helper'

describe "The constructor helper" do

  it "should allow assignments by hash" do
    org.mitre.cybox.core.ObservableType.new(:title => 'Testing').title.should == 'Testing'
    org.mitre.cybox.core.ObservableType.new('title' => 'Testing').title.should == 'Testing'
  end

  it "should raise an error when passing hashes with invalid values" do
    expect { org.mitre.cybox.core.ObservableType.new(:blah => 'Testing') }.to raise_error
  end

  it "should work with XML names" do
    org.mitre.cybox.core.ObservableType.new('Title' => 'Testing').title.should == 'Testing'
  end

  it "should allow assigning values automatically" do
    org.mitre.cybox.common.StringObjectPropertyType.new('hi').value.should == 'hi'
    obj = org.mitre.cybox.common.StringObjectPropertyType.new('hi', :regex_syntax => "mine")
    obj.value.should == 'hi'
    obj.regex_syntax.should == "mine"
  end

  it "should not assign IDs when they are suppressed" do
    org.mitre.cybox.common.StringObjectPropertyType.new('hi').id.should == nil
  end

  it "should assign list items automatically" do
    # Try it with actual objects
    spec = org.mitre.data_marking.MarkingSpecificationType.new(:controlled_structure => "//node()")
    marking = org.mitre.data_marking.MarkingType.new(:markings => [spec])
    marking.markings.length.should == 1
    marking.markings.first.should be_kind_of(org.mitre.data_marking.MarkingSpecificationType)

    # Use hash constructor
    marking = org.mitre.data_marking.MarkingType.new(:markings => [{:controlled_structure => "//node()"}])
    marking.markings.length.should == 1
    marking.markings.first.should be_kind_of(org.mitre.data_marking.MarkingSpecificationType)
  end

  it "should create list items automatically" do
    org.mitre.cybox.common.ToolsInformationType.new([
      {
        :name => "Calamine",
        :description => "COA_DESCRIPTION"
      }
    ])
  end

  it "should create list items when multi-level" do
    ttp = org.mitre.stix.ttp.TTPType.new(
      :title => 'Test',
      :behavior => {
        :attack_patterns => [{:description => 'Test'}]
      }
    )

    ttp.behavior.attack_patterns.attack_patterns.first.description.value.should == 'Test'
  end
end