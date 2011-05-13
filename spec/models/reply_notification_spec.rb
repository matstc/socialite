require 'spec_helper'

describe ReplyNotification do
  it "should understand there are pending reply notifications" do
    user = ObjectMother.create_user
    comment = ObjectMother.create_comment
    notification = ObjectMother.create_reply_notification :user => user, :comment => comment

    user.reload
    user.reply_notifications.include?(notification).should == true
  end

  it "should be for a top level comment if the comment has no parent" do
    parent = ObjectMother.create_comment
    comment = ObjectMother.create_comment :parent => parent
    notification = ObjectMother.create_reply_notification :comment => comment
    notification.is_for_a_top_level_comment.should == false

    notification = ObjectMother.create_reply_notification
    notification.is_for_a_top_level_comment.should == true
  end

end
