class Comment < ActiveRecord::Base
  has_many :children, :class_name => "Comment", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "Comment"
  belongs_to :submission
  belongs_to :user
  validates :user, :presence => true
  validates :text, :presence => true
  default_scope :order => "created_at DESC"

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
end
