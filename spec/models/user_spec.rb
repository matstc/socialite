require 'spec_helper'

describe User do
  it "should destroy everything related to a user" do
    user = ObjectMother.create_user :username => 'short-lived'
    submission = ObjectMother.create_submission :user => user
    spam_submission = ObjectMother.create_submission :user => user, :is_spam => true
    reply_to_spam_submission = ObjectMother.create_comment :submission => spam_submission
    comment = ObjectMother.create_comment :user => user
    reply_to_comment = ObjectMother.create_comment :parent => comment
    spam_reply_to_comment = ObjectMother.create_comment :parent => reply_to_comment, :is_spam => true
    other_person_comment = ObjectMother.create_comment :submission => submission
    notification_for_user = ObjectMother.create_reply_notification :user => user
    notification_triggered_by_user = ObjectMother.create_reply_notification :comment => comment

    user.reload
    user.destroy

    User.where(:id => user.id).all.should == []
    Submission.where(:id => submission.id).all.should == []
    Submission.where(:id => spam_submission.id).all.should == []
    Comment.where(:id => comment.id).all.should == []
    Comment.where(:id => reply_to_comment.id).all.should == []
    Comment.where(:id => reply_to_spam_submission.id).all.should == []
    Comment.where(:id => spam_reply_to_comment.id).all.should == []
    Comment.where(:id => other_person_comment.id).all.should == []
    ReplyNotification.where(:id => notification_for_user.id).all.should == []
    ReplyNotification.where(:id => notification_triggered_by_user.id).all.should == []
  end

  it "should know whether or not it has reply notifications" do
    user = ObjectMother.create_user
    user.has_notifications?.should == nil
    ObjectMother.create_reply_notification :user => user
    user.reload

    user.has_notifications?.should == true
  end

  it "should know whether or not it has spam notifications" do
    user = ObjectMother.create_user :admin => true
    user.has_notifications?.should == false
    ObjectMother.create_spam_notification
    user.reload

    user.has_notifications?.should == true
  end

  it "should not have spam notifications as normal user" do
    user = ObjectMother.create_user
    user.has_notifications?.should == nil
    ObjectMother.create_spam_notification
    user.reload

    user.has_notifications?.should == nil
  end

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

  it "should soft delete a user as well its submissions/comments/notifications" do
    user = ObjectMother.create_user :username => 'short-lived'
    submission = ObjectMother.create_submission :user => user
    comment = ObjectMother.create_comment :user => user
    notification_for_user = ObjectMother.create_reply_notification :user => user
    notification_triggered_by_user = ObjectMother.create_reply_notification :comment => comment

    user.reload
    user.mark_as_deleted
    user.save!
    submission.reload
    comment.reload

    user.deleted?.should == true
    comment.deleted?.should == true
    submission.deleted?.should == true
    ReplyNotification.where(:id => notification_for_user.id).all.should == []
    ReplyNotification.where(:id => notification_triggered_by_user.id).all.should == []
  end

end
