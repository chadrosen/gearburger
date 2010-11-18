class AddTrackingPixel < ActiveRecord::Migration
  def self.up
    add_column(:user_product_emails, :viewed, :boolean, :null => false, :default => false)
    add_column(:user_product_emails, :viewed_at, :datetime, :null => true)    
  end

  def self.down
    remove_column(:user_product_emails, :viewed)
    remove_column(:user_product_emails, :viewed_at)    
  end
end
