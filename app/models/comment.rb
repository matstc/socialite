class Comment < ActiveRecord::Base
  has_many :children, :class_name => "Comment", :foreign_key => "parent_id"

  belongs_to :parent, :class_name => "Comment"
  belongs_to :submission
  belongs_to :user

  validates :user, :presence => true
  validates :text, :presence => true
  validates_uniqueness_of :text, :scope => [:submission_id, :parent_id, :user_id]

  after_create :create_reply_notification
  before_create :trim
  
  default_scope :order => "created_at DESC"
  scope :not_deleted_or_spam, :readonly => false, :joins => [:user,:submission], :conditions => ["(submissions.is_spam is ? OR submissions.is_spam = ?) AND (comments.is_spam is ? OR comments.is_spam = ?) AND (users.deleted is ? OR users.deleted = ?)", nil, false, nil, false, nil, false]

  def self.recent_comments
    Comment.not_deleted_or_spam.limit(20).all.select{|c| !c.is_orphan?}[0,12]
  end

  def trim
    self.text.gsub!(/[\r\n]*$/,"")
  end

  def create_reply_notification
    create_reply_notification_for(has_parent? ? self.parent : self.submission)
  end

  def create_reply_notification_for resource
    ReplyNotification.create!(:user => resource.user, :comment => self) if resource.user != self.user
  end

  def has_parent?
    !self.parent.nil?
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

  def is_orphan?
    return true if deleted_or_spam?

    if has_parent?
      return self.parent.is_orphan?
    end

    false
  end

  def to_s
    self.text
  end

  def number_of_replies
    self.children.size
  end

  def destroy_recursively
      children = Comment.where(:parent_id => self.id)
      children.each {|child| child.destroy_recursively}
      self.destroy
  end
end
