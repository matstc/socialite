class ReplyNotification < ActiveRecord::Base
  belongs_to :user
  belongs_to :comment

  validates :comment, :presence => true
  validates :user, :presence => true

  default_scope :order => "created_at DESC"

  def is_for_a_top_level_comment
    ! self.comment.has_parent?
  end
end
