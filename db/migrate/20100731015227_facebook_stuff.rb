class FacebookStuff < ActiveRecord::Migration
  def self.up
    add_column(:users, :fb_user_id, :integer, :null => true)
  end

  def self.down
    remove_column(:users, :fb_user_id)
  end
end