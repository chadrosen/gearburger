class AddCampaignIdtoUser < ActiveRecord::Migration
  def self.up
    add_column(:users, :campaign_id, :string, :null => true)
  end

  def self.down
    remove_column(:users, :campaign_id)
  end
end
