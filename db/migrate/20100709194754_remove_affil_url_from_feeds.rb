class RemoveAffilUrlFromFeeds < ActiveRecord::Migration
  def self.up
    remove_column(:feeds, :affiliate_url)
  end

  def self.down
  end
end
