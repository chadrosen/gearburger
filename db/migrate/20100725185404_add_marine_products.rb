class AddMarineProducts < ActiveRecord::Migration
  def self.up
    Feed.create!(:name => "Marine Products", :active => true, 
      :url => "http://datafeed.avantlink.com/download_feed.php?auth=b94ac9d3911f69692d14e0cefe1fb960" )
  end

  def self.down
  end
end
