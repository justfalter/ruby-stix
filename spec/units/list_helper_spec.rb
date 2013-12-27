require 'spec_helper'

describe "The list helper" do

  it "should correctly detect additions to plural types and add them" do
    observables = org.mitre.cybox.core.ObservablesType.new
    expect {observables.add_observable(org.mitre.cybox.core.ObservableType.new)}.to_not raise_error
    observables.observables.length.should == 1
  end

  it "should raise an error on incorrect additions" do
    observables = org.mitre.cybox.core.ObservablesType.new
    expect {observables.add_nonsense(org.mitre.cybox.core.ObservableType.new)}.to raise_error
  end

end