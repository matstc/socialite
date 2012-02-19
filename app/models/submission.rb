require 'uri'

class Submission < ActiveRecord::Base
  SECONDS_PER_DAY = 86400

  belongs_to :user
  has_many :all_comments, :class_name => 'Comment'
  has_many :votes

  validates :user, :presence => true
  validates :title, :presence => true
  validates :description, :presence => true

  after_initialize :setup_default_values

  paginates_per 20

  scope :ordered_by_created_date, :order => "created_at DESC"

  scope :not_deleted_or_spam, :readonly => false, :joins => :user, :conditions => ["(is_spam is ? OR is_spam = ?) AND (users.deleted is ? OR users.deleted = ?)", nil, false, nil, false]

  # Here we order by interestingness.
  scope :ordered, lambda { {:order => "submissions.score * #{SECONDS_PER_DAY / AppSettings.voting_momentum} - strftime('%s','now') + strftime('%s',submissions.created_at) DESC"} }

  # Interestingness is calculated by multiplying the number of votes by a coefficient.
  # The amount of time passed since creation is taken as a penalty.
  # Equivalent ruby code would go like this:
  def interestingness
    self.score * (SECONDS_PER_DAY / AppSettings.voting_momentum) - Time.now.to_i + created_at.to_i
  end

  def setup_default_values
    self.score ||= 0
    if !self.url.blank?
      self.url = "http://" + url if !self.url.nil? and self.url !~ /^[a-zA-Z]*:\/\//
    end
    self.is_spam ||= false
  end

  def self.most_recent
    Submission.not_deleted_or_spam.order("submissions.created_at DESC")
  end

  def self.best_of
    Submission.not_deleted_or_spam.order("submissions.score DESC")
  end

  def self.list
    # Since default_scope cannot take a lambda argument -- we make do here by overriding list and manually specifying the default scope as :ordered
    Submission.not_deleted_or_spam.ordered
  end

  def comments
    self.all_comments.reject {|comment| comment.is_orphan?}
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
    self.comments.reject {|comment| comment.has_parent?}
  end

  def mark_as_spam
    self.is_spam = true
  end

  def deleted?
    self.user.deleted?
  end

  def to_s
    "#{self.title} #{self.description}"
  end

end
