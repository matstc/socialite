require 'spec_helper'

describe Comment do
  it "should remove carriage returns from the end of a comment" do
    comment = ObjectMother.create_comment :text => "this is a test.\r\n\r\n"
    comment.text.should == "this is a test."
  end

  it "should be an orphan if any ancestor is spam or deleted even if the oldest ancestor is not spam" do
    great_grand_parent = ObjectMother.create_comment
    grand_parent = ObjectMother.create_comment :parent => great_grand_parent, :is_spam => true, :user => ObjectMother.create_user(:deleted => true)
    parent = ObjectMother.create_comment :parent => grand_parent
    comment = ObjectMother.create_comment :parent => parent
    Comment.find(comment.id).is_orphan?.should == true
  end

  it "should be an orphan if any ancestor is spam or deleted" do
    grand_parent = ObjectMother.create_comment :is_spam => true, :user => ObjectMother.create_user(:deleted => true)
    parent = ObjectMother.create_comment :parent => grand_parent
    comment = ObjectMother.create_comment :parent => parent
    Comment.find(comment.id).is_orphan?.should == true
  end

  it "should be an orphan if the parent is spam or deleted" do
    parent = ObjectMother.create_comment :is_spam => true, :user => ObjectMother.create_user(:deleted => true)
    comment = ObjectMother.create_comment :parent => parent
    Comment.find(comment.id).is_orphan?.should == true
  end

  it "should still see its parent even if it's deleted or spam" do
    parent = ObjectMother.create_comment :is_spam => true, :user => ObjectMother.create_user(:deleted => true)
    comment = ObjectMother.create_comment :parent => parent
    Comment.find(comment.id).has_parent?.should == true
  end

  describe "recent comments" do
    it "should only include comments that were not marked as spam and whose author was not deleted" do
      all_comments = []
      20.times { all_comments << ObjectMother.create_comment }
      all_comments << ObjectMother.create_comment(:is_spam => true)
      all_comments << ObjectMother.create_comment(:user => ObjectMother.create_user(:deleted => true))

      Comment.recent_comments.should == all_comments.reverse[2,12]
    end

    it "should not pull up orphan comments" do
      all_comments = []
      20.times { all_comments << ObjectMother.create_comment }
      parent = ObjectMother.create_comment(:is_spam => true)
      all_comments << parent
      all_comments << ObjectMother.create_comment(:parent => parent)

      Comment.recent_comments.should == all_comments.reverse[2,12]
    end
  end

  it "should create a notification when leaving a comment on another user's submission" do
    user = ObjectMother.create_user
    submission = ObjectMother.create_submission :user => user

    user.reply_notifications.empty?.should == true
    comment = ObjectMother.create_comment :submission => submission
    user.reload
    user.reply_notifications.empty?.should == false
    user.reply_notifications.first.comment.should == comment
    user.reply_notifications.first.user.should == user
  end

  it "should not create a notification when leaving a comment on your own submission" do
    user = ObjectMother.create_user
    submission = ObjectMother.create_submission :user => user

    user.reply_notifications.empty?.should == true
    comment = ObjectMother.create_comment :submission => submission, :user => user
    user.reload
    user.reply_notifications.empty?.should == true
  end

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
    user.reply_notifications.first.comment.should == comment
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

  it "should know that it is spam" do
    comment = ObjectMother.new_comment :is_spam => true
    comment.is_spam?.should be(true)
  end
end
