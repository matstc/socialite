require 'spec_helper'

describe NotificationMailer do
  include ApplicationHelper

  it "should generate a notification email" do
	#require File.expand_path("../../app/helpers/application_helper", __FILE__)
    ActionMailer::Base.default_url_options[:host] = 'localhost'
	reply_notification = ObjectMother.create_reply_notification

    mail = NotificationMailer.send_notification reply_notification

    mail.to[0].should == reply_notification.user.email
    mail.subject.should == "[Socialite] #{reply_notification.comment.user} replied to you"
	url = link_to_comment(reply_notification.comment)
	mail.encoded.include?(url).should == true
  end
end

