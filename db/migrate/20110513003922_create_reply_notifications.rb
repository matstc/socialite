class CreateReplyNotifications < ActiveRecord::Migration
  def self.up
    create_table :reply_notifications do |t|
      t.integer :user_id
      t.integer :comment_id

      t.timestamps
    end
  end

  def self.down
    drop_table :reply_notifications
  end
end
