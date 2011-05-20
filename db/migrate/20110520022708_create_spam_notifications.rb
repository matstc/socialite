class CreateSpamNotifications < ActiveRecord::Migration
  def self.up
    create_table :spam_notifications do |t|
      t.integer :comment_id
      t.integer :submission_id

      t.timestamps
    end
  end

  def self.down
    drop_table :spam_notifications
  end
end
