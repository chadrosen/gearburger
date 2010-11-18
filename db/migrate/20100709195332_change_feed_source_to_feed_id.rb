class ChangeFeedSourceToFeedId < ActiveRecord::Migration
  def self.up
    remove_column(:product_generation_summaries, :feed_source)
    add_column(:product_generation_summaries, :feed_id, :integer, :null => false)
  end

  def self.down
  end
end
