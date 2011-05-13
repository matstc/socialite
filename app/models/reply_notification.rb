class ReplyNotification < ActiveRecord::Base
  belongs_to :user
  belongs_to :comment

  validates :comment, :presence => true
  validates :user, :presence => true
end
