class InactivateBcFeed < ActiveRecord::Migration
  def self.up
    f = Feed.find_by_name("Backcountry Outlet")
    f.active = false
    f.save!
  end

  def self.down
  end
end
