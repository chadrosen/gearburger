class AddValidProductChecks < ActiveRecord::Migration
  def self.up
    add_column(:products, :valid_sale_price, :boolean, :default => true, :null => false)
    add_column(:products, :valid_small_image, :boolean, :default => true, :null => false)
  end

  def self.down
    remove_column(:products, :valid_sale_price)
    remove_column(:products, :valid_small_image)
  end
end
