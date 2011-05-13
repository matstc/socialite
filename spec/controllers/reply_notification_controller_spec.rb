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
end
