require 'spec_helper'

describe SpamNotificationController do
  include ControllerMocking

  before(:each) do
    mock_user :admin => true
  end

  it "should ignore the destroying of a notification that does not exist" do
    delete :destroy, :id => "1"
  end

  it "destroys the spam notification" do
    notification = ObjectMother.create_spam_notification
    delete :destroy, :id => notification.id
    SpamNotification.all.include?(notification).should == false
  end

  it "should delete all spam notifications" do
    notification = ObjectMother.create_spam_notification

    delete :dismiss_all
    SpamNotification.all.include?(notification).should == false
  end
end
