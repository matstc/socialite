require 'spec_helper'

describe AdminController do
  include Devise::TestHelpers
  include ControllerMocking

  before(:each) do
    mock_user :admin => true

    @antispam = ObjectMother.initialize_antispam_filter
    Antispam.stub(:new){ @antispam }
    @initial_entry_count = @antispam.trained_entries

  end

  describe "signing in as a deleted user" do
	it "should sign the user out and redirect to root url" do
	  controller.current_user.mark_as_deleted
	  get :index
	  response.location.should == root_url
	  warden.authenticated?(:user).should == false
	end
  end

  describe "save meta tags" do
    it "should update settings with the meta tags" do
      post :save_meta_tags, :app_settings => {:meta_description => "description", :meta_keywords => "keywords"}
      AppSettings.meta_description.should == "description"
      AppSettings.meta_keywords.should == "keywords"
    end
  end

  describe "save twitter" do
    it "should update settings with the twitter consumer token and secret" do
      post :save_twitter, :app_settings => {:twitter_consumer_key => "key", :twitter_consumer_secret => "secret"}
      AppSettings.twitter_consumer_key.should == "key"
      AppSettings.twitter_consumer_secret.should == "secret"
    end
  end

  describe "save google analytics script" do
    it "should update settings with the new google analytics script" do
      post :save_google_analytics, :app_settings => {:google_analytics_script => "<script>!</script>"}
      AppSettings.google_analytics_script.should == "<script>!</script>"
    end
  end

  describe "save interestingness" do
    it "should update settings with the new voting momentum" do
      post :save_interestingness, :app_settings => {:voting_momentum => "123"}
      AppSettings.voting_momentum.should == 123
    end
  end

  describe "modify appearance" do
    it "should build up a list of themes by looking at all the directories under public/stylesheets" do
      get :modify_appearance
      assigns[:themes].should =~ ["default", "dark", "dusk"]
    end
  end

  describe "save appearance" do
    it "should save the new theme" do
      post :save_appearance, :app_settings => {:theme => 'test-theme'}
      flash[:notice].blank?.should == false
      AppSettings.theme.should == 'test-theme'
    end
  end

  describe "save automatic notifications" do
    it "should update settings with the new recipient email or the new disabled state" do
      post :save_automatic_notifications, :app_settings => {:exception_notifier_recipient => "test-recipient"}
      AppSettings.exception_notifier_recipient.should == "test-recipient"
    end

    it "should toggle on and off the exception notifier" do
      post :save_automatic_notifications, :app_settings => {:exception_notifier_enabled => "1"}
      AppSettings.exception_notifier_enabled.should == true

      post :save_automatic_notifications, :app_settings => {:exception_notifier_enabled => "0"}
      AppSettings.exception_notifier_enabled.should == false
    end
  end

  describe "moderate submissions" do
    it "should list submissions to moderate including spam ones" do
      spammer = ObjectMother.create_user
      submission = ObjectMother.create_submission :user => spammer, :is_spam => true
      get :moderate_submissions
      assigns(:submissions).should == [submission]
    end
  end

  describe "moderate comments" do
    it "should list comments to moderate" do
      comment = ObjectMother.create_comment
      get :moderate_comments
      assigns(:comments).should == [comment]
    end
  end

  describe "save about page" do
    it "should save the new about page to settings" do
      post :save_about_page, :app_settings => {:about_page => 'new-test-page'}
      flash[:notice].blank?.should == false
      AppSettings.about_page.should == 'new-test-page'
    end
  end

  describe "save app name" do
    it "should save the new app name to settings" do
      post :save_app_name, :app_settings => {:app_name => 'new-test-name'}
      flash[:notice].blank?.should == false
      AppSettings.app_name.should == 'new-test-name'
    end
  end

  describe "test exception notifier" do
    it "should send an email to the exception notifier recipient" do
      class FakeEmail; def deliver; end; end
      TestEmailMailer.stub(:send_test_email){FakeEmail.new}

      post :test_exception_notifier

      flash[:notice].blank?.should == false
      response.should redirect_to(:automatic_notifications)
    end
  end

  describe "send test email" do
    it "should send a test email through the test email mailer" do
      class FakeEmail; def deliver; end; end
      TestEmailMailer.stub(:send_test_email){FakeEmail.new}

      post :send_test_email, :test_email => {:email => "user@example.com"}

      flash[:notice].blank?.should == false
      response.should redirect_to(:email_settings)
    end
  end

  describe "email settings" do
    it "should consider a setting of '0' to be false" do 
      post :save_email_settings, :app_settings => {:smtp_tls => "0"}
      AppSettings.smtp_tls.should == false
    end

    it "should consider a setting of '1' to be true" do 
      post :save_email_settings, :app_settings => {:smtp_tls => "1"}
      AppSettings.smtp_tls.should == true
    end

    it "should consider a string like '123' for the port to be a number" do
      post :save_email_settings, :app_settings => {:smtp_port => "123"}
      AppSettings.smtp_port.should == 123
    end
  end

  describe "marking comment as spam" do
    it "should mark comment as spam and train the antispam filter" do
      comment = ObjectMother.create_comment :text => 'commenting'

      post :mark_comment_as_spam, :id => comment.id
      @antispam.trained_entries.should == @initial_entry_count + 1
      comment.reload.is_spam?.should == true
      @antispam.is_classified_as_spam?(comment).should == true

      post :undo_mark_comment_as_spam, :id => comment.id
      @antispam.trained_entries.should == @initial_entry_count + 1
      comment.reload.is_spam?.should == false
      @antispam.is_classified_as_spam?(comment).should == false
    end
  end

  describe "marking submission as spam" do
    it "should mark submission as spam and train the antispam filter" do
      @submission = ObjectMother.create_submission :title => 'one', :description => 'two'
      post :mark_submission_as_spam, :id => @submission.id

      @antispam.trained_entries.should == @initial_entry_count + 2
      @submission.reload.is_spam?.should == true
      @antispam.is_classified_as_spam?(@submission).should == true

      post :undo_mark_submission_as_spam, :id => @submission.id
      @antispam.trained_entries.should == @initial_entry_count + 2
      @submission.reload.is_spam?.should == false
      @antispam.is_classified_as_spam?(@submission).should == false
    end
  end

end
