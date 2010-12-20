class RemovePuCacheColumn < ActiveRecord::Migration
  def self.up
    drop_table(:products_users)
    remove_column(:user_product_emails, :products_users_count)
  end

  def self.down
  end
end
