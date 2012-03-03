require 'spec_helper'

describe Statistics do
  describe "loading statistics" do
    it "should retrieve the bundle of statistics" do
      user = ObjectMother.create_user
      submission = ObjectMother.create_submission :user => user

      stats = Statistics.load
      stats[:number_of_users].should == 1
      stats[:number_of_submissions].should == 1
    end
	
    it "should fetch the registration time of the last created user" do
      user_alphabetically_first = ObjectMother.create_user :username => 'a'
	  second_user = ObjectMother.create_user :username => 'b'

      stats = Statistics.load
      stats[:time_of_last_registration].to_i.should == second_user.created_at.to_i
    end
  end
end
