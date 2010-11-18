class AddBreakStateToUser < ActiveRecord::Migration
  def self.up
    change_column(:users, :state, :enum, :limit => [:pending, :active, :inactive, :break], :default => :pending)
    add_column(:users, :break_started_at, :datetime, :null => true)
    add_column(:users, :break_ends_at, :datetime, :null => true)
  end

  def self.down
    change_column(:users, :state, :enum, :limit => [:pending, :active, :inactive], :default => :pending)
    remove_column(:users, :break_started_at)
    remove_column(:users, :break_ends_at)
  end
end
