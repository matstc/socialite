require 'spec_helper'

describe ReplyNotification do
  it "should understand there are pending reply notifications" do
    user = ObjectMother.create_user
    comment = ObjectMother.create_comment
    notification = ObjectMother.create_reply_notification :user => user, :comment => comment

    user.reload
    user.reply_notifications.include?(notification).should == true
  end

end
