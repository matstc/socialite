class Comment < ActiveRecord::Base
  has_many :children, :class_name => "Comment", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "Comment"
  belongs_to :submission
  belongs_to :user
  validates :user, :presence => true
  validates :text, :presence => true
  default_scope :order => "created_at DESC"

  after_save :create_reply_notification

  def create_reply_notification
    if self.parent and self.parent.user != self.user
      ReplyNotification.create! :user => self.parent.user, :comment => self.parent
    elsif not self.parent and self.submission.user != self.user
      ReplyNotification.create! :user => self.submission.user, :comment => self
    end
  end

  def has_parent
    !self.parent.nil?
  end

  def deleted?
    self.user.deleted?
  end

  def spam_or_deleted?
    deleted? || is_spam?
  end

  def mark_as_spam
    self.is_spam = true
  end

  def to_s
    self.text
  end

  def number_of_replies
    self.children.size
  end
end
