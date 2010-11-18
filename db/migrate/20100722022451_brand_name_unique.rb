class BrandNameUnique < ActiveRecord::Migration
  def self.up
    # Turn this off for now until we fix the data.
    #add_index(:brands, :name, :unique => true)
  end

  def self.down
  end
end
