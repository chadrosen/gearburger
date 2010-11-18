class MoreClicksChanges < ActiveRecord::Migration
  def self.up
    add_column(:clicks, :source, :text, :null => true)
    add_column(:clicks, :version, :integer, :null => false, :default => 0)
    change_column(:clicks, :click_type, :enum, :null => false,
      :limit => [:product_email_link, :alert_email_link, :alert_link, :product_link, :search_link, :coupon_link])
  end

  def self.down
  end
end
