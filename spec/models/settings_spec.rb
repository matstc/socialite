require 'spec_helper'

describe AppSettings do
  it "should reload setting as a number" do
    AppSettings.foo = 123
    AppSettings.foo.should == 123
  end

  it "should save settings from a hash of params" do
    AppSettings.update_settings :a => 1, :b => 2
    AppSettings.a.should == 1
    AppSettings.b.should == 2
  end

  it "should save smtp port and voting momentum as numbers" do
    AppSettings.update_settings :smtp_port => "2", :voting_momentum => "2"
    AppSettings.smtp_port.should == 2
    AppSettings.voting_momentum.should == 2
  end

  it "should not allow voting momentum to be less than 2" do
    AppSettings.update_settings :voting_momentum => "-1"
    AppSettings.voting_momentum.should == 2
    AppSettings.update_settings :voting_momentum => "0"
    AppSettings.voting_momentum.should == 2
    AppSettings.update_settings :voting_momentum => "1"
    AppSettings.voting_momentum.should == 2
  end
end

