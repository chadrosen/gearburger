class AddPriceChangesToEmailSummary < ActiveRecord::Migration
  def self.up
    add_column(:product_generation_summaries, :price_changes, :integer, :default => 0, :null => false)
    
    # Attempt to add counter cache for user product emails sent in each summary
    add_column(:user_product_emails, :products_users_count, :integer, :default => 0, :null => false)
  end

  def self.down
  end
end
