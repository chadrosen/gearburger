class SomeDbCleanup < ActiveRecord::Migration
  def self.up
    remove_column(:products, :large_image_url)
    remove_column(:products, :manufacturer_id)
  end

  def self.down
    add_column(:products, :large_image_url, :string, :null => true)
    add_column(:products, :manufacturer_id, :string, :null => true)
  end
end
