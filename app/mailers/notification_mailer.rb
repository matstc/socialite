class NotificationMailer < ActionMailer::Base
  include ApplicationHelper 
  helper :application

  def send_notification reply_notification
	@reply_notification = reply_notification
	email = @reply_notification.user.email
	from = @reply_notification.comment.user

	Rails.logger.info("Sending notification email to #{@reply_notification.user} about comment ##{@reply_notification.comment.id}")

    mail(:to => email,
         :from => "no-reply@#{AppSettings.smtp_domain}",
         :subject => "[#{app_name}] #{from} replied to you")
  end
end
