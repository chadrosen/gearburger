class DecactivationReasonCanBeNull < ActiveRecord::Migration
  def self.up
    change_column(:users, :deactivation_reason, :text, :null => true)
  end

  def self.down
    change_column(:users, :deactivation_reason, :text, :null => false)
  end
end
