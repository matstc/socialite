class AddAllowEmailNotificationsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :allow_email_notifications, :boolean
  end

  def self.down
    remove_column :users, :allow_email_notifications
  end
end
