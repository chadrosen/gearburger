class AddUserInviteAcceptedState < ActiveRecord::Migration
  def self.up
    change_column(:user_invites, :state, :enum, :limit => [:pending, :sent, :error, :created], :default => :pending)
  end

  def self.down
    change_column(:user_invites, :state, :enum, :limit => [:pending, :sent, :error], :default => :pending)    
  end
end
