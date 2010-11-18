class RemoveOldProductFields < ActiveRecord::Migration
  def self.up
    remove_column(:products, :recent_alert_id)
    remove_column(:products, :permalink)
  end

  def self.down
  end
end
