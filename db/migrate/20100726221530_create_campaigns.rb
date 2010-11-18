class CreateCampaigns < ActiveRecord::Migration
  def self.up
    create_table :campaigns do |t|
      t.string :public_id, :null => false
      t.string :name, :null => false
      t.text :description, :null => true
      t.timestamps
    end

    remove_column(:users, :campaign_id)
    add_column(:users, :campaign_id, :integer, :null => true)
    add_index(:users, :campaign_id)
    add_index(:campaigns, :public_id, :unique => true)
  end

  def self.down
    drop_table :campaigns
    remove_column(:users, :campaign_id)
    add_column(:users, :campaign_id, :string, :null => true)
    
  end
end
