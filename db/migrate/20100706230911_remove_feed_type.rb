class RemoveFeedType < ActiveRecord::Migration
  def self.up
    Feed.delete_all("feed_type = 'alert'")
    remove_column(:feeds, :feed_type)
  end

  def self.down
  end
end
