class AddCouponClick < ActiveRecord::Migration
  def self.up
    change_column(:clicks, :click_type, :enum, :limit => [:alert_link, :product_link, :search_link, :coupon_link], :null => false)
  end

  def self.down
  end
end
