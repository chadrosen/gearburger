class AddStatetoCampaign < ActiveRecord::Migration
  def self.up
    add_column(:campaigns, :active, :boolean, :null => false, :default => true)
  end

  def self.down
    remove_column(:campaigns, :active)
  end
end
