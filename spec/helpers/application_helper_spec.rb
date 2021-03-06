require 'spec_helper'

describe ApplicationHelper do

  it "should escape the site name when generating the html for the button" do
    AppSettings['app_name'] = '<">'
    helper.button_html.should =~ /&lt;&quot;&gt;/
  end

  it "should enable the twitter provider in the middleware" do
    AppSettings['twitter_consumer_key'] = 'key'
    AppSettings['twitter_consumer_secret'] = 'secret'
    helper.setup_omniauth
    Socialite::Application.config.twitter_enabled.should == true
  end

  describe "page title" do
    it "should concatenate the page title and the application name" do
      helper.page_title.should == app_name
      helper.set_page_title "test title"
      helper.page_title.should == "test title | #{app_name}"
    end
  end

  describe "sanitize html" do
    it "should only allow some tags to come through" do
      sanitize_html("I <b>want</b> <i>this</i> to <a>not link</a>").should == "I <b>want</b> <i>this</i> to &lt;a&gt;not link&lt;/a&gt;"
    end
  end
  
  describe "link_to_comment" do
    it "should link to the comment including the scrolling id" do
      comment = ObjectMother.create_comment
      link_to_comment(comment).should == "/submissions/#{comment.submission.id}#comment-#{comment.id}"
    end
  end

  describe "error_messages!" do
    it "should generate error messages" do
      def resource
        user = User.new
        user.errors[:username] = "test-error"
        user
      end

      def resource_name
        "user"
      end
      error_messages!.should match /test-error/
    end
  end

  describe "theme helpers" do
    it "should resolve the directory for specified theme" do
      theme_directory(:test).should == "public/stylesheets/themes/test"
    end

    it "should resolve the path to the theme file for specified theme" do
      theme_file(:test).should == "public/stylesheets/themes/test/theme.css"
    end

    it "should resolve the directory storing all themes" do
      themes_directory.should == "public/stylesheets/themes"
    end
  end

  describe "resolve submission url" do
    it "should replace blank with a link to the comments" do
      submission = ObjectMother.create_submission :url => "http://google.com"
      helper.resolve_submission_url(submission).should == "http://google.com"

      submission = ObjectMother.create_submission :url => ""
      helper.resolve_submission_url(submission).should == submission_path(submission)
    end
  end

  describe "app name" do
    it "should return the name of the app" do
      AppSettings.app_name = 'test-name'
      helper.app_name.should == 'test-name'
    end
  end

  describe "time ago in words including ago" do
    it "should return 1 minute ago" do 
        text = helper.time_ago_in_words_including_ago 1.minute.ago
        text.should == "1 minute ago"
    end
  end

  describe "resolve class for coloring comment" do
    it "should not add anything to the class names if comment is legit" do
      comment = mock(Comment, :is_spam? => false).as_null_object
      helper.resolve_class_for_coloring_comment(comment).should == ""
    end

    it "should add marked-as-spam to the class names if comment is spam" do
      comment = mock(Comment, :is_spam? => true).as_null_object
      helper.resolve_class_for_coloring_comment(comment).should == "marked-as-spam"
    end
  end

end
