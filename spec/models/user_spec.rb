require 'spec_helper'

describe User do
  it "should not allow two users with the same username" do
    one = ObjectMother.create_user :username => "test-username"
    lambda { ObjectMother.create_user :email => 'unique-email@example.com', :username => one.username }.should raise_error
  end

  it "should fetch highest karma users" do
    highest = ObjectMother.create_user :karma => 10
    lowest = ObjectMother.create_user :karma => 5
    User.highest_karma_users.should == [highest, lowest]
  end

  it "should auto confirm all users by default without confirmation email" do
    ObjectMother.create_user.confirmed?.should be(true)
  end

  it "should let devise confirm users if settings say so" do
    ActionMailer::Base.default_url_options[:host] = 'localhost'
    AppSettings.confirm_email_on_registration = true
    ObjectMother.create_user.confirmed?.should be(false)
  end

  it "should know if user already voted for a submission" do
    user = ObjectMother.create_user
    submission = ObjectMother.create_submission

    user.voted_for(submission).should == false
    user.can_vote_for(submission).should == true
    ObjectMother.create_vote user, submission
    user.voted_for(submission).should == true
    user.can_vote_for(submission).should == false
  end

  it "should not allow voting if author is current user" do
    user = ObjectMother.create_user
    submission = ObjectMother.create_submission :user => user

    user.can_vote_for(submission).should == false
  end

  it "should increase karma as its submissions are voted up" do
    david = User.new
    david.karma.should eq(0)
    Submission.new(:user => david).vote_up User.new
    david.karma.should eq(1)
  end

  it "should list spammers with a spam comment" do
    spammer = ObjectMother.create_user :username => 'spammer'
    legit_user = ObjectMother.create_user :username => 'legit'
    spam_comment = ObjectMother.create_comment :user => spammer, :is_spam => true

    User.find_spammers.all.should include(spammer)
    User.find_spammers.all.should_not include(legit_user)
  end

  it "should list spammers with a spam submission" do
    spammer = ObjectMother.create_user :username => 'spammer'
    legit_user = ObjectMother.create_user :username => 'legit'
    spam_submission = ObjectMother.create_submission :user => spammer, :is_spam => true

    User.find_spammers.all.should include(spammer)
    User.find_spammers.all.should_not include(legit_user)
  end

  it "should mark a user as deleted and do the same for its submissions and comments" do
    user = ObjectMother.new_user :username => 'short-lived'
    submission = ObjectMother.new_submission :user => user
    comment = ObjectMother.new_comment :user => user

    user.mark_as_deleted

    user.deleted?.should be(true)
    submission.deleted?.should be(true)
    comment.deleted?.should be(true)
  end

end
