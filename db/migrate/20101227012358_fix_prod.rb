class FixProd < ActiveRecord::Migration
  def self.up
    
    drop_table(:experiments)
    remove_column(:products, :large_image_url)
    remove_column(:products, :manufacturer_id)
    drop_table(:products_users)
    remove_column(:user_product_emails, :products_users_count)

  end

  def self.down
  end
end
