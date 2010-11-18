class TrackUserInfoOnReg < ActiveRecord::Migration
  def self.up
    add_column(:users, :ip_address, :string, :null => true)
    add_column(:users, :user_agent, :string, :null => true)
    add_column(:users, :identity_hash, :string, :null => true)
  end

  def self.down
    remove_column(:users, :ip_address)
    remove_column(:users, :user_agent)
  end
end
