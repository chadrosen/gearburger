class AddDeptOfGoods < ActiveRecord::Migration
  def self.up
    Feed.create!(:name => "DepartmentOfGoods.com", 
      :url => "http://datafeed.avantlink.com/download_feed.php?auth=b94ac9d3911f69692d14e0cefe1fb960",
      :active => true)
  end

  def self.down
  end
end
