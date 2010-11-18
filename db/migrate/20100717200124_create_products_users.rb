class CreateProductsUsers < ActiveRecord::Migration
  def self.up
    create_table :products_users do |t|
      t.integer :user_product_email_id, :null => false
      t.integer :product_id, :null => false
      t.integer :user_id, :null => false
      t.boolean :clicked, :null => false, :default => false
      t.timestamp :clicked_at, :null => true
      t.timestamps
    end
  end

  def self.down
    drop_table :products_users
  end
end
