class DropOldTables < ActiveRecord::Migration
  def self.up
    
    # Drop old tables
    drop_table :alerts
    drop_table :alerts_users
    drop_table :blocked_products
    drop_table :followed_products
    drop_table :recent_alerts
    drop_table :search_results
    drop_table :coupons
    
    # Truncate data from tables that are product related
    Product.delete_all
    ProductPrice.delete_all
    UserProductEmail.delete_all
    ProductGenerationSummary.delete_all
  end

  def self.down
  end
end
