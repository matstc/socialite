class AddDeletedToUser < ActiveRecord::Migration
  def self.up
    #This column is no longer used
    #add_column :users, :deleted, :boolean
  end

  def self.down
    #remove_column :users, :deleted
  end
end
