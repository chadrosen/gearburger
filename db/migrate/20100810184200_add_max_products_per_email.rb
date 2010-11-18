class AddMaxProductsPerEmail < ActiveRecord::Migration
  def self.up
    add_column(:users, :max_products_per_email, :integer, :default => 99, :null => false)
  end

  def self.down
    remove_column(:users, :max_products_per_email)
  end
end
