class CreateUserInvites < ActiveRecord::Migration
  def self.up
    
    create_table :user_invites do |t|
      t.integer :user_id, :null => false
      t.string :email_address, :null => false
      t.timestamps
    end

    add_index(:user_invites, :user_id) # Look up invitees for a user
    add_index(:user_invites, :email_address) # Look up who invited whom

    add_column(:users, :referral_id, :integer, :null => true)
  end

  def self.down
    drop_table :user_invites
    remove_column(:users, :referral_id)
  end
end
