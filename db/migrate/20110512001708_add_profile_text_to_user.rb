class AddProfileTextToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :profile_text, :text
  end

  def self.down
    remove_column :users, :profile_text
  end
end
