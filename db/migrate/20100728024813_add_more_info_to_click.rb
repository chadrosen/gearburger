class AddMoreInfoToClick < ActiveRecord::Migration
  def self.up
    add_column(:clicks, :user_product_email_id, :integer, :null => true)
    add_column(:clicks, :products_user_id, :integer, :null => true)
    add_column(:clicks, :product_id, :integer, :null => true)
    
    # Remove old enum props
    change_column(:clicks, :click_type, :enum, :limit => [:product_email_link, :product_link])
    
    # Don't really need these now that users are required to login
    remove_column(:clicks, :user_agent)
    remove_column(:clicks, :ip_address)
    remove_column(:clicks, :user_hash)
    remove_column(:clicks, :cookie)    
  end

  def self.down
    remove_column(:clicks, :user_product_email_id)
    remove_column(:clicks, :products_user_id)
    remove_column(:clicks, :product_id)
  end
end
