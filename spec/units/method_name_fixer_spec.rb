require 'spec_helper'

describe "The method name fixer" do
  it "should fix TTPs" do
    org.mitre.stix.ttp.TTPType.new.should respond_to(:related_ttps)
  end
end