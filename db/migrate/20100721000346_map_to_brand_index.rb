class MapToBrandIndex < ActiveRecord::Migration
  def self.up
    add_index(:brands, :map_to_id)
  end

  def self.down
    remove_index(:brands, :map_to_id)
  end
end
