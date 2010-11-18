class EvenMoreFeeds < ActiveRecord::Migration
  def self.up
    Feed.create!(:name => "Giantnerd", :url => "http://datafeed.avantlink.com/download_feed.php?auth=b94ac9d3911f69692d14e0cefe1fb960")
    Feed.create!(:name => "Half-Moon Outfitters", :url => "http://datafeed.avantlink.com/download_feed.php?auth=b94ac9d3911f69692d14e0cefe1fb960")
    Feed.create!(:name => "Konasports.com", :url => "http://datafeed.avantlink.com/download_feed.php?auth=b94ac9d3911f69692d14e0cefe1fb960")
    Feed.create!(:name => "OutdoorBasics.com", :url => "http://datafeed.avantlink.com/download_feed.php?auth=b94ac9d3911f69692d14e0cefe1fb960")
    Feed.create!(:name => "o2 Gear Shop", :url => "http://datafeed.avantlink.com/download_feed.php?auth=b94ac9d3911f69692d14e0cefe1fb960")
    Feed.create!(:name => "Snowboards.net", :url => "http://datafeed.avantlink.com/download_feed.php?auth=b94ac9d3911f69692d14e0cefe1fb960")
    Feed.create!(:name => "MasseysOutfitters.com", :url => "http://datafeed.avantlink.com/download_feed.php?auth=b94ac9d3911f69692d14e0cefe1fb960")
    Feed.create!(:name => "RamseyOutdoor.com", :url => "http://datafeed.avantlink.com/download_feed.php?auth=b94ac9d3911f69692d14e0cefe1fb960")
    Feed.create!(:name => "FontanaSports.com", :url => "http://datafeed.avantlink.com/download_feed.php?auth=b94ac9d3911f69692d14e0cefe1fb960")
    Feed.create!(:name => "ParagonSports.com", :url => "http://datafeed.avantlink.com/download_feed.php?auth=b94ac9d3911f69692d14e0cefe1fb960")
  end

  def self.down
  end
end
