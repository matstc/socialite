require 'spec_helper'

describe Comment do
  include ControllerMocking 

  it "should not allow two identical comments to be submitted by the same user within a minute of one another" do
	options = {:text => "test-comment4236786", :user => ObjectMother.create_user, :submission => ObjectMother.create_submission}
	ObjectMother.create_comment options

	options_for_non_duplicate = options.dup
	options_for_non_duplicate[:text] = "This is an older comment which should not be compared for duplicity!"
	ObjectMother.create_comment options_for_non_duplicate

	lambda {ObjectMother.create_comment options}.should raise_error
  end

  it "should remove carriage returns from the end of a comment" do
	comment = ObjectMother.create_comment :text => "this is a test.\r\n\r\n\r\n"
	comment.text.should == "this is a test."
  end

  it "should allow only two new lines in the middle of a comment" do
	comment = ObjectMother.create_comment :text => "first line\r\n\r\n\r\n\r\nsecond line\r\n"
	comment.text.should == "first line\n\nsecond line"
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

  it "should not list spam comments as children" do
	parent = ObjectMother.create_comment
	spam_comment = ObjectMother.create_comment :parent => parent, :is_spam => true
	relevant_comment = ObjectMother.create_comment :parent => parent
	parent.reload

	parent.children.should == [relevant_comment]
  end

  describe "recent comments" do
	it "should only include comments that were not marked as spam and whose author was not deleted" do
	  all_comments = []
	  20.times { all_comments << ObjectMother.create_comment }
	  all_comments << ObjectMother.create_comment(:is_spam => true)
	  all_comments << ObjectMother.create_comment(:user => ObjectMother.create_user(:deleted => true))

	  Comment.recent_comments.should == all_comments.reverse[2,15]
	end

	it "should not pull up orphan comments" do
	  all_comments = []
	  20.times { all_comments << ObjectMother.create_comment }
	  parent = ObjectMother.create_comment(:is_spam => true)
	  all_comments << parent
	  all_comments << ObjectMother.create_comment(:parent => parent)

	  Comment.recent_comments.should == all_comments.reverse[2,15]
	end
  end

  it "should survive an error while emailing a reply notification" do
	class FakeEmail; def deliver; raise "the test should have survived this"; end; end
	NotificationMailer.should_receive(:send_notification).and_return(FakeEmail.new)
	AppSettings.email_enabled = true

	user = ObjectMother.create_user
	submission = ObjectMother.create_submission :user => user
	ObjectMother.create_comment :submission => submission
  end

  it "should create notifications when leaving a comment on another user's submission" do
	class FakeEmail; def deliver;end;end
	NotificationMailer.should_receive(:send_notification).and_return(FakeEmail.new)
	AppSettings.email_enabled = true

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
	NotificationMailer.should_not_receive(:send_notification)
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
	parent.reload
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

  it "should not send an email notification if the admin did not set email settings" do
	NotificationMailer.should_not_receive(:send_notification)
	AppSettings.email_enabled = false

	user = ObjectMother.create_user :allow_email_notifications => true
	submission = ObjectMother.create_submission :user => user
	ObjectMother.create_comment :submission => submission
  end

  it "should not send an email notification if the user has disallowed emails" do
	NotificationMailer.should_not_receive(:send_notification)
	AppSettings.email_enabled = true

	user = ObjectMother.create_user :allow_email_notifications => false
	submission = ObjectMother.create_submission :user => user
	ObjectMother.create_comment :submission => submission
  end
end
