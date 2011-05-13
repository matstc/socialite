require 'spec_helper'

describe ReplyNotificationController do
  include ControllerMocking

  it "destroys the reply notification" do
    user = mock_user
    notification = ObjectMother.new_reply_notification :user => user
    notification.id = 1
    ReplyNotification.stub(:where).with(:user_id => notification.user, :id => notification.id) { [ notification ] }
    notification.should_receive(:destroy)

    delete :destroy, :id => notification.id
  end

  it "should not destroy someone else's notification" do
    user = mock_user
    notification = ObjectMother.create_reply_notification

    lambda { delete :destroy, :id => notification.id }.should raise_error
  end

  it "should delete all reply notifications of the current user" do
    user = mock_user
    own_notification = ObjectMother.create_reply_notification :user => user
    other_notification = ObjectMother.create_reply_notification

    delete :dismiss_all
    ReplyNotification.all.include?(other_notification).should == true
    ReplyNotification.all.include?(own_notification).should == false
  end
end
