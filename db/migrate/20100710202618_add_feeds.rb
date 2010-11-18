class AddFeeds < ActiveRecord::Migration
  def self.up
    Feed.reset_column_information
    Feed.create(:name => 'evogear.com', :url => 'http://datafeed.avantlink.com/download_feed.php?auth=b94ac9d3911f69692d14e0cefe1fb960')
    Feed.create(:name => 'Moosejaw', :url => 'http://datafeed.avantlink.com/download_feed.php?auth=b94ac9d3911f69692d14e0cefe1fb960')
    Feed.create(:name => 'Altrec.com Outdoors (New)', :url => 'http://datafeed.avantlink.com/download_feed.php?auth=b94ac9d3911f69692d14e0cefe1fb960')
    Feed.create(:name => 'AltrecOutlet.com', :url => 'http://datafeed.avantlink.com/download_feed.php?auth=b94ac9d3911f69692d14e0cefe1fb960')
    Feed.create(:name => 'CampSaver.com', :url => 'http://datafeed.avantlink.com/download_feed.php?auth=b94ac9d3911f69692d14e0cefe1fb960')  
  end

  def self.down
  end
end
