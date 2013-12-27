require 'spec_helper'

describe "The ID helper" do

  it "should create IDs when none are assigned" do
    org.mitre.cybox.core.ObservableType.new.id.should_not be_nil
  end

  it "should not overwrite IDs when they are assigned" do
    id = javax.xml.namespace.QName.new("testing-an-id")
    org.mitre.cybox.core.ObservableType.new(:id => id).id.should == id
  end

  it "should not try to set IDs on objects that don't support it" do
    expect {org.mitre.cybox.core.ObservablesType.new }.to_not raise_error
  end

end