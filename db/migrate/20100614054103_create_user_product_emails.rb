class CreateUserProductEmails < ActiveRecord::Migration
  def self.up
    
    create_table :user_product_emails do |t|
      t.integer :user_id, :null => false
      t.boolean :sent, :null => false, :default => false
      t.datetime :sent_at, :null => true
      t.boolean :clicked, :null => false, :default => false
      t.datetime :clicked_at, :null => true
      t.timestamps    
    end
    
    add_index(:user_product_emails, :user_id)
  end

  def self.down
    drop_table :user_product_emails
  end
end
