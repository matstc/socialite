class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  validates_presence_of :username
  validates_uniqueness_of :username

  validates :karma, :presence => true

  attr_accessible :email, :password, :password_confirmation, :remember_me, :username, :karma, :profile_text, :deleted

  has_many :submissions
  has_many :comments
  has_many :votes
  has_many :reply_notifications
  has_many :authentications

  paginates_per 50

  default_scope :order => "username"

  after_initialize :setup_default_values

  before_destroy :destroy_related_objects

  def self.find_spammers
    User.includes([:submissions, :comments]).group("users.id").where(["submissions.is_spam = ? or comments.is_spam = ?", true, true])
  end

  def self.highest_karma_users
    User.unscoped.where('karma != 0').order('karma DESC').limit(20)
  end

  def setup_default_values
    self[:karma] ||= 0
    self[:confirmed_at] ||= Time.now if !AppSettings.confirm_email_on_registration
  end

  def destroy_related_objects
    destroy_related_notifications

    Comment.where(:user_id => self).all.each do |comment|
      comment.destroy_recursively
    end

    all_submissions = Submission.where(:user_id => self)
    all_submissions.all.each do |submission|
      Comment.where(:submission_id => submission).delete_all
    end

    all_submissions.delete_all
    self.authentications.destroy_all
  end

  def has_notifications?
    !reply_notifications.empty? or (self.try(:admin) and SpamNotification.count > 0)
  end

  def voted_for submission
    Vote.where(:user_id => self.id, :submission_id => submission.id).count > 0
  end

  def can_vote_for submission
    submission.user != self and !voted_for(submission)
  end

  def increment_karma
    self.karma += 1
  end

  def to_s
    self.attributes['username']
  end

  def mark_as_deleted
    self.deleted = true
    destroy_related_notifications
  end

  def destroy_related_notifications
    self.reply_notifications.destroy_all
    ReplyNotification.where(:comment_id => self.comments.map{|c|c.id}).destroy_all
  end

  def linked_to? provider
    ! self.authentications.find_by_provider(:twitter).nil?
  end

end
