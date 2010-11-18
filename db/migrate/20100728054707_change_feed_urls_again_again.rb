class ChangeFeedUrlsAgainAgain < ActiveRecord::Migration
  def self.up
    remove_column(:feeds, :development_url)
    remove_column(:feeds, :test_url)
    remove_column(:feeds, :staging_url)
    rename_column(:feeds, :production_url, :url)
  end

  def self.down
  end
end
