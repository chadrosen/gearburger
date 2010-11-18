class AddUserAgentClickTracking < ActiveRecord::Migration
  def self.up
    add_column(:clicks, :user_agent, :string, :null => true)
    add_column(:clicks, :ip_address, :string, :null => true)
    add_column(:clicks, :user_hash, :string, :null => true)
  end

  def self.down
    remove_column(:clicks, :user_agent)
    remove_column(:clicks, :ip_address)
    remove_column(:clicks, :user_hash)
  end
end
