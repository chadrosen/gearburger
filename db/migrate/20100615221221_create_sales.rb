class CreateSales < ActiveRecord::Migration
  def self.up
    create_table :sales do |t|
      
      t.integer  :click_id, :null => true
      
      t.string   :custom_tracking_code, :null => true
      t.integer  :order_id, :null => true
      t.string   :transaction_id, :null => false
      t.decimal  :transaction_amount, :precision => 10, :scale => 2, :default => 0.0, :null => false
      t.decimal  :total_commission, :precision => 10, :scale => 2, :default => 0.0, :null => false
      t.datetime :transaction_time, :null => false
      t.datetime :last_click_through, :null => true

      t.string   :merchant_name, :null => false
      t.integer  :merchant_id, :null => false
      t.string   :product_name, :null => true
      
      t.datetime :created_at, :null => false      
    end
    
    add_index(:sales, :click_id)
    add_index(:sales, [:transaction_id, :merchant_id]) # identifies unique row on avantlink
    
  end

  def self.down
    drop_table :sales
  end
end
