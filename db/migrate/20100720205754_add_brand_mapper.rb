class AddBrandMapper < ActiveRecord::Migration
  def self.up
    add_column(:brands, :map_to_id, :integer, :null => true)
  end

  def self.down
  end
end
