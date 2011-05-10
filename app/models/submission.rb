require 'uri'

class Submission < ActiveRecord::Base
  belongs_to :user
  has_many :all_comments, :class_name => 'Comment'
  has_many :votes

  validates :user, :presence => true
  validates :title, :presence => true
  validates :description, :presence => true

  after_initialize :setup_default_values

  paginates_per 20

  # Here we order by interestingness.
  scope :ordered, lambda { {:order => "submissions.score * #{AppSettings.voting_momentum} - strftime('%s','now') + strftime('%s',submissions.created_at) DESC"} }

  # Interestingness is calculated by multiplying the number of votes by a coefficient.
  # The amount of time passed since creation is taken as a penalty.
  # Equivalent ruby code would go like this:
  def interestingness
    self.score * AppSettings.voting_momentum - Time.now.to_i + created_at.to_i
  end

  def setup_default_values
    self.score ||= 0
    if !self.url.blank?
      self.url = "http://" + url if !self.url.nil? and self.url !~ /^[a-zA-Z]*:\/\//
    end
    self.is_spam ||= false
  end

  def self.most_recent
    Submission.unscoped.where(:is_spam => false).order("created_at DESC")
  end

  def self.best_of
    Submission.unscoped.where(:is_spam => false).order("score DESC")
  end

  def self.list
    # Since default_scope cannot take a lambda argument -- we make do here by overriding list and manually specifying the default scope as :ordered
    # Also, I could not find a way to default the value of :deleted to false so we fetch all users where :deleted is null or false
    Submission.ordered.joins(:user).where("is_spam = ? AND users.deleted IS NULL OR users.deleted = ?", false, false)
  end

  def comments
    self.all_comments.reject {|comment| comment.spam_or_deleted?}
  end

  def comments= args
    self.all_comments = args
  end

  def vote_up user_who_voted
    if not Vote.where(:submission_id => self.id, :user_id => user_who_voted.id).empty?
      logger.warn "User #{user_who_voted} tried to vote twice for submission ##{self.id}"
    elsif user_who_voted == self.user
      logger.warn "User #{user_who_voted} tried to vote for their own submission ##{self.id}"
    else
      self.score += 1
      self.user.increment_karma
      Vote.new(:user => user_who_voted, :submission => self).save
      self.save
      self.user.save
    end
    self
  end

  def top_level_comments
    self.comments.reject {|comment| comment.has_parent}
  end

  def mark_as_spam
    self.is_spam = true
  end

  def to_s
    "#{self.title} #{self.description}"
  end

  def deleted?
    self.user.deleted?
  end

end
