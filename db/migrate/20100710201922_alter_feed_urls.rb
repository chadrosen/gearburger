class AlterFeedUrls < ActiveRecord::Migration
  def self.up
    Feed.update_all("url = 'http://datafeed.avantlink.com/download_feed.php?auth=b94ac9d3911f69692d14e0cefe1fb960'")
  end

  def self.down
  end
end
