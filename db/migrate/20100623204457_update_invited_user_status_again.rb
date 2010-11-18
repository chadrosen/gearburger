class UpdateInvitedUserStatusAgain < ActiveRecord::Migration
  def self.up
    # Change this back..
    change_column(:user_invites, :state, :enum, :limit => [:pending, :sent, :error], :default => :pending)
    
    # Just use the user's table for succesfully added users
    add_index(:users, :referral_id)
  end

  def self.down
    remove_index(:users, :referral_id)
  end
end
