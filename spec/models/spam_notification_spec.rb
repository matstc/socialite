require 'spec_helper'

describe SpamNotification do
  it "should not allow saving to database if there are no comment or submission" do
    SpamNotification.new(:submission => ObjectMother.new_submission).save.should == true
    SpamNotification.new(:comment => ObjectMother.new_comment).save.should == true
    SpamNotification.new.save.should == false
  end

  it "should be for a comment if comment is not nil" do
    SpamNotification.new.is_for_a_comment?.should == false
    SpamNotification.new(:comment => ObjectMother.new_comment).is_for_a_comment?.should == true
  end
end
