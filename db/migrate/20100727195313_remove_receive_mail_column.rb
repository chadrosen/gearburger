class RemoveReceiveMailColumn < ActiveRecord::Migration
  def self.up
    remove_column(:email_day_preferences, :receive_email)
  end

  def self.down
    add_column(:email_day_preferences, :receive_email, :boolean, :default => true, :null => false)
  end
end
