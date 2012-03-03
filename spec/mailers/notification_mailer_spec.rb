require 'spec_helper'

describe NotificationMailer do
  it "should generate a notification email" do
    ActionMailer::Base.default_url_options[:host] = 'localhost'
	reply_notification = ObjectMother.create_reply_notification

    mail = NotificationMailer.send_notification reply_notification

    mail.to[0].should == reply_notification.user.email
    mail.subject.should == "[Socialite] #{reply_notification.comment.user} replied to you"
	url = comment_url(reply_notification.comment, :host => 'localhost')
	mail.encoded.include?(url).should == true
  end
end

