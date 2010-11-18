class UserPricePreference < ActiveRecord::Migration
  def self.up
    add_column(:users, :min_discount, :decimal, :null => false, :default => 0.0, :precision => 10, :scale => 2)
    add_column(:users, :min_price, :decimal, :null => false, :default => 0.0, :precision => 10, :scale => 2)
    add_column(:users, :max_price, :decimal, :null => false, :default => 0.0, :precision => 10, :scale => 2)
    
    User.reset_column_information
    User.update_all("min_discount = 0.2, min_price = 0.0, max_price = 5000.00")
    
  end

  def self.down
    remove_column(:users, :min_discount)
    remove_column(:users, :min_price)
    remove_column(:users, :max_price)
  end
end
