class InviteUserState < ActiveRecord::Migration
  def self.up
    add_column(:user_invites, :state, :enum, :limit => [:pending, :sent, :error], :default => :pending)
    add_column(:user_invites, :sent_at, :datetime, :null => true)
    add_column(:user_invites, :error_msg, :string, :null => true)
  end

  def self.down
  end
end
