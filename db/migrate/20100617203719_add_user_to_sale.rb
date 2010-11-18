class AddUserToSale < ActiveRecord::Migration
  def self.up
    add_column(:sales, :user_id, :integer, :null => true)
    add_index(:sales, :user_id)
  end

  def self.down
    remove_index(:sales, :user_id)
    remove_column(:sales, :user_id)
  end
end
