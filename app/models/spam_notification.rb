class SpamNotification < ActiveRecord::Base
  belongs_to :comment
  belongs_to :submission

  validates :comment, :presence => {:unless => "submission", :message => "you need to specify at least a comment or a submission"}

  def is_for_a_comment?
    !self.comment.nil?
  end
end
