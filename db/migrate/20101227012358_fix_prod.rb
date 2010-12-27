class FixProd < ActiveRecord::Migration
  def self.up
    remove_column(:user_product_emails, :products_users_count)
  end

  def self.down
  end
end
