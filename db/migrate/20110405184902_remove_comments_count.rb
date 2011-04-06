class RemoveCommentsCount < ActiveRecord::Migration
  def self.up
    remove_column :submissions, :comments_count
  end

  def self.down
    add_column :submissions, :comments_count, :integer, :default => 0

    Submission.reset_column_information
    Submission.find(:all).each do |p|
      Submission.update_counters p.id, :comments_count => p.comments.length
    end
  end
end
