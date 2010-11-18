class AddAbingoIdentity < ActiveRecord::Migration
  def self.up
    add_column(:users, :abingo_identity, :string, :null => true)
  end

  def self.down
    remove_column(:users, :abingo_identity)
  end
end
