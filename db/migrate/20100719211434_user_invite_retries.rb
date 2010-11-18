class UserInviteRetries < ActiveRecord::Migration
  def self.up
    add_column(:user_invites, :attempts, :integer, :default => 0, :null => false)
  end

  def self.down
  end
end
