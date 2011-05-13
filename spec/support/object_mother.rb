class ObjectMother
  @@user_count = 0

  def self.initialize_antispam_filter
    FileUtils.rm_rf("test-antispam-memory") if File.exists? "test-antispam-memory"
    antispam ||= Antispam.new "test-antispam-memory"
    antispam.train_as_spam "buy this"
    antispam.train_as_content "serious matter"
    antispam
  end

  def self.create_vote user, submission
    vote = Vote.new :user => user, :submission => submission
    vote.save!
    vote
  end

  def self.create_user options={}
    user = new_user(options)
    user.save!
    user
  end

  def self.new_user options={}
    options[:username] ||= "test-user-#{@@user_count += 1}" 
    options[:email] ||= "#{options[:username]}@example.com"
    options[:password] ||= "123456"
    options[:password_confirmation] ||= "123456"
    TestLogger.log "creating test user with options = #{options}"
    User.new options
  end

  def self.create_submission options={}
    submission = new_submission(options)
    submission.save!
    submission
  end

  def self.new_submission options={}
    options[:title] ||= 'title'
    options[:url] ||= 'example.com'
    options[:description] ||= 'description'
    options[:is_spam] ||= false
    options[:user] ||= random_user
    TestLogger.log "creating test submission with options = #{options}"
    Submission.new options
  end

  def self.create_reply_notification options={}
    notification = new_reply_notification options
    notification.save!
    notification
  end

  def self.new_reply_notification options={}
    options[:comment] ||= new_comment
    options[:user] ||= new_user
    ReplyNotification.new options
  end

  def self.create_comment options={}
    comment = new_comment(options)
    comment.save!
    comment
  end

  def self.new_comment options={}
    options[:submission] ||= new_submission
    options[:text] ||= 'test-text'
    options[:user] ||= random_user
    TestLogger.log "creating a test comment with options = #{options}"
    Comment.new options
  end

  def self.random_user
    create_user :username => "test-user#{Time.now.to_f}"
  end
end
