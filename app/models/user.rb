class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  validates_presence_of :username
  validates_uniqueness_of :username

  validates :karma, :presence => true

  attr_accessible :email, :password, :password_confirmation, :remember_me, :username, :karma, :deleted, :profile_text

  has_many :submissions
  has_many :comments

  after_initialize :setup_default_values

  def self.find_spammers
    User.includes([:submissions, :comments]).group("users.id").where(["submissions.is_spam = ? or comments.is_spam = ?", true, true])
  end

  def self.highest_karma_users
    User.order('karma DESC').limit(10)
  end

  def setup_default_values
    self[:karma] ||= 0
    self[:confirmed_at] ||= Time.now if !AppSettings.confirm_email_on_registration
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
  end

end
