class CleanUpEmailInfo < ActiveRecord::Migration
  def self.up
    remove_column(:users, :email_start_time)
    remove_column(:users, :email_end_time)
    remove_column(:users, :email_days)
    remove_column(:users, :send_alert_email)
    remove_column(:users, :send_price_email)
  end

  def self.down
  end
end