class AddFbShareCampaign < ActiveRecord::Migration
  def self.up
    Campaign.create!(:public_id => "fbshare", :name => "FB share user", 
      :description => "Users created from facebook share")
  end

  def self.down
  end
end
