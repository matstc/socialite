require 'spec_helper'

describe Comment do
  it "should not create a reply notifcation when replying to your own comment" do
    user = ObjectMother.create_user
    submission = ObjectMother.create_submission
    parent_comment = ObjectMother.create_comment :submission => submission, :user => user

    user.reply_notifications.empty?.should == true
    comment = ObjectMother.create_comment :submission => submission, :parent => parent_comment, :user => user
    user.reload
    user.reply_notifications.empty?.should == true
  end

  it "should create a reply notification when leaving a comment" do
    user = ObjectMother.create_user
    submission = ObjectMother.create_submission
    parent_comment = ObjectMother.create_comment :submission => submission, :user => user

    user.reply_notifications.empty?.should == true
    comment = ObjectMother.create_comment :submission => submission, :parent => parent_comment
    user.reload
    user.reply_notifications.empty?.should == false
    user.reply_notifications.first.user.should == user
    user.reply_notifications.first.comment.should == parent_comment
  end

  it "should know how many replies a comment has" do
    parent = ObjectMother.create_comment
    first_child = ObjectMother.create_comment :parent => parent
    parent.reload
    parent.number_of_replies.should == 1

    second_child = ObjectMother.create_comment :parent => parent
    parent.number_of_replies.should == 2
  end

  it "should not validate if text is empty" do
    comment = ObjectMother.new_comment :text => ""
    comment.save.should == false
  end

  it "should default to not spam" do
    comment = Comment.new
    comment.is_spam?.should be(false)
  end

  it "should be possible to get the children of the children" do
    top = Comment.new :text => "top"
    middle = Comment.new :parent => top, :text => "middle"
    bottom = Comment.new :parent => middle, :text => "bottom"

    bottom.parent.parent.should eq(top)
  end

  it "should know it the user author of the comment was deleted" do
    user = ObjectMother.new_user
    comment = ObjectMother.new_comment :user => user
    comment.spam_or_deleted?.should be(false)

    user.mark_as_deleted
    comment.spam_or_deleted?.should be(true)
  end

  it "should know that it is spam" do
    comment = ObjectMother.new_comment :is_spam => true
    comment.spam_or_deleted?.should be(true)
  end
end
