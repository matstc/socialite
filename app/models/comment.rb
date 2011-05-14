class Comment < ActiveRecord::Base
  has_many :children, :class_name => "Comment", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "Comment"
  belongs_to :submission
  belongs_to :user
  validates :user, :presence => true
  validates :text, :presence => true

  after_save :create_reply_notification
  
  default_scope :order => "created_at DESC"
  default_scope :readonly => false, :joins => :user, :conditions => ["(is_spam is ? OR is_spam = ?) AND (users.deleted is ? OR users.deleted = ?)", nil, false, nil, false]

  def self.recent_comments
    Comment.limit(12).all
  end

  def create_reply_notification
    create_reply_notification_for(has_parent? ? self.parent : self.submission)
  end

  def create_reply_notification_for resource
    ReplyNotification.create!(:user => resource.user, :comment => self) if resource.user != self.user
  end

  def has_parent?
    !self.parent.nil? || !self.parent_id.nil? # looking for parent_id here because if we look only for parent.nil? then it might be nil just because parent is deleted or spam
  end

  def mark_as_spam
    self.is_spam = true
  end

  def deleted?
    self.user.deleted?
  end

  def deleted_or_spam?
    deleted? || self.is_spam
  end

  def to_s
    self.text
  end

  def number_of_replies
    self.children.size
  end

  def destroy_recursively
      children = Comment.unscoped.where(:parent_id => self.id)
      children.each {|child| child.destroy_recursively}
      self.destroy
  end
end
