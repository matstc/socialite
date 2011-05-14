module ApplicationHelper
  def sanitize_html text
    s = text.dup

    # escaping html to html entities 
    s = s.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;') 

    # allow blockquote
    s.gsub!(/\n?&lt;blockquote&gt;\n*(.+?)\n*&lt;\/blockquote&gt;/im, "<blockquote>\\1</blockquote>") 

    # other tags: b, i, em, strong, u 
    %w(b i em strong u).each do |x|
      s.gsub!(Regexp.new('&lt;(' + x + ')&gt;(.+?)&lt;/('+x+')&gt;',
           Regexp::MULTILINE|Regexp::IGNORECASE), 
           "<\\1>\\2</\\1>") 
    end

    s
  end

  def link_to_comment comment
    "#{submission_path(comment.submission)}#comment-#{comment.id}"
  end

  def bookmarklet_url
    "javascript:window.location=%22#{new_submission_url}?submission[url]=%22+encodeURIComponent(document.location)+%22&submission[title]=%22+encodeURIComponent(document.title)"
  end

  def app_name
    AppSettings.app_name
  end

  def theme
    AppSettings.theme
  end

  def icon name
    %{<span class="ui-icon ui-icon-#{name}"></span>}
  end

  def theme_directory name
    "#{themes_directory}/#{name}"
  end

  def theme_file name
    "#{theme_directory name}/theme.css"
  end

  def themes_directory
    "public/stylesheets/themes"
  end

  # this is a customized version or devise_error_messages! in devise_helper.rb
  def error_messages!
    return "" if resource.errors.empty?

    messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    sentence = I18n.t("errors.messages.not_saved",
                      :count => resource.errors.count,
                      :resource => resource_name)

    html = <<-HTML
  <div id="error_explanation">
  <h3>#{sentence}</h3>
  <ul>#{messages}</ul>
  </div>
    HTML

    html.html_safe
  end

  def time_ago_in_words_including_ago time
    return nil if time.nil?
    "#{time_ago_in_words(time)} ago"
  end

  def link_to_unless_current_action text, path
    options = Rails.application.routes.recognize_path(path, :method => :get)
    if options[:controller] == controller.controller_name and options[:action] == controller.action_name 
      return text
    end

    link_to text, path
  end

  def current_user_is_admin?
    current_user.try :admin
  end

  def resolve_class_for_coloring_comment comment
    classes = []
    classes << "marked-as-spam" if comment.is_spam?
    classes.join " "
  end

  def resolve_class_for_coloring_submission submission
    classes = []
    classes << "dim" if !current_user.nil? && !current_user.can_vote_for(submission)
    classes << "marked-as-spam" if submission.is_spam?
    classes.join " "
  end

  def resolve_submission_url submission
    submission.url.blank? ? submission_path(submission) : submission.url
  end

  def setup_action_mailer
    ActionMailer::Base.default_url_options[:host] = AppSettings.smtp_default_url_host
    ActionMailer::Base.smtp_settings = {
      :address => AppSettings.smtp_address,
      :port => AppSettings.smtp_port,
      :domain => AppSettings.smtp_domain,
      :authentication => AppSettings.smtp_authentication,
      :user_name => AppSettings.smtp_authentication_username,
      :password => AppSettings.smtp_authentication_password,
      :tls => AppSettings.smtp_tls,
      :enable_starttls_auto => AppSettings.smtp_enable_starttls_auto,
    }

  end

  def setup_exception_notifier
    Socialite::Application.config.middleware.use ::ExceptionNotifierToggler
    Socialite::Application.config.middleware.use ::ExceptionNotifier
  end

end
