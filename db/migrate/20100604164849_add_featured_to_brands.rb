class AddFeaturedToBrands < ActiveRecord::Migration
  def self.up
    add_column(:brands, :popular, :boolean, :default => false, :null => false)
    add_index(:brands, :popular)
  end

  def self.down
    remove_index(:brands, :popular)
    remove_column(:brands, :popular)
  end
end
