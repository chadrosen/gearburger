class NewFeeds < ActiveRecord::Migration
  def self.up
    Feed.create!(:name => "Patagonia.com", :url => "http://datafeed.avantlink.com/download_feed.php?auth=b94ac9d3911f69692d14e0cefe1fb960")
    Feed.create!(:name => "GearX.com", :url => "http://datafeed.avantlink.com/download_feed.php?auth=b94ac9d3911f69692d14e0cefe1fb960")
    Feed.create!(:name => "Bike.com", :url => "http://datafeed.avantlink.com/download_feed.php?auth=b94ac9d3911f69692d14e0cefe1fb960")
    Feed.create!(:name => "Skis.com", :url => "http://datafeed.avantlink.com/download_feed.php?auth=b94ac9d3911f69692d14e0cefe1fb960")
    Feed.create!(:name => "USOutdoorStore.com", :url => "http://datafeed.avantlink.com/download_feed.php?auth=b94ac9d3911f69692d14e0cefe1fb960")
  end

  def self.down
  end
end
