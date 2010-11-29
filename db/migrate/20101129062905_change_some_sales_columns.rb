class ChangeSomeSalesColumns < ActiveRecord::Migration
  def self.up
    change_column(:sales, :order_id, :string, :null => true)
    change_column(:sales, :merchant_id, :string, :null => true)
  end

  def self.down
    change_column(:sales, :order_id, :integer, :null => true)
    change_column(:sales, :merchant_id, :integer, :null => true)
  end
end
