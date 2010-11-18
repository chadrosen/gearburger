class OhterPermalinksToRemove < ActiveRecord::Migration
  def self.up
    remove_column(:categories, :permalink)
    remove_column(:brands, :permalink)
  end

  def self.down
  end
end
