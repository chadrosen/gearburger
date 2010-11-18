class AddManufacturerId < ActiveRecord::Migration
  def self.up
    add_column(:products, :manufacturer_id, :string, :null => true)
  end

  def self.down
  end
end
