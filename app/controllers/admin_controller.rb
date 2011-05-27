class AdminController < ApplicationController
  before_filter :require_admin!

  def raise_dummy_error
    raise Exception.new "This is a dummy error for testing error handling. Ignore it safely."
  end

  def index
  end

  def modify_appearance
    @themes = Dir["#{themes_directory}/*"].map { |a| File.basename(a) }
  end

  def save_google_analytics
      AppSettings.update_settings params[:app_settings]
      redirect_to :setup_google_analytics, :notice => 'Settings saved.'
  end

  def save_interestingness
      AppSettings.update_settings params[:app_settings]
      redirect_to :tweak_interestingness, :notice => 'Settings saved.'
  end

  def save_appearance
      AppSettings.update_settings params[:app_settings]
      redirect_to :modify_appearance, :notice => 'The theme was changed.'
  end

  def moderate_comments
    @comments = Comment.unscoped.order("created_at DESC").page params[:page]
  end

  def moderate_submissions
    @submissions = Submission.unscoped.order("created_at DESC").page params[:page]
  end

  def save_about_page
      AppSettings.update_settings params[:app_settings]
      redirect_to :modify_about_page, :notice => 'The new about page was saved.'
  end

  def save_app_name
      AppSettings.update_settings params[:app_settings]
      redirect_to :change_name, :notice => 'The new name was saved.'
  end

  def test_exception_notifier
    address = AppSettings.exception_notifier_recipient
    deliver_test_email address
    redirect_to :automatic_notifications
  end

  def send_test_email
    address = params[:test_email][:email]
    deliver_test_email address
    redirect_to :email_settings
  end

  def deliver_test_email address
    begin
      TestEmailMailer.send_test_email(address).deliver
      flash[:notice] = "Test email sent. You should soon receive an email at #{address}."
    rescue Exception => e
      flash[:alert] = "Could not send test email: #{e}"

      logger.warn flash[:alert]
      logger.warn e.backtrace
    end
  end

  def save_automatic_notifications
    AppSettings.update_settings params[:app_settings]
    redirect_to :automatic_notifications, :notice => 'Settings saved.'
  end

  def save_email_settings
    AppSettings.update_settings params[:app_settings]
    setup_action_mailer
    redirect_to :email_settings, :notice => 'Settings saved.'
  end

  def mark_comment_as_spam
    submission = Comment.find params[:id]
    mark_resource_as_spam submission
  end

  def mark_submission_as_spam
    submission = Submission.find params[:id]
    mark_resource_as_spam submission
  end

  def mark_resource_as_spam submission
    submission.mark_as_spam
    Antispam.new.switch_to_spam submission
    submission.save
    render :text => "({id: #{submission.id}, message: '#{I18n.t 'marked_as_spam'}'})"
  end
  
  def undo_mark_comment_as_spam
    submission = Comment.unscoped.find params[:id]
    undo_mark_resource_as_spam submission
  end

  def undo_mark_submission_as_spam
    submission = Submission.unscoped.find params[:id]
    undo_mark_resource_as_spam submission
  end

  def undo_mark_resource_as_spam submission
    submission.is_spam = false
    submission.save
    Antispam.new.switch_to_content submission
    render :text => "({id: #{submission.id}, message: '#{I18n.t 'no_longer_marked_as_spam'}'})"
  end

end
