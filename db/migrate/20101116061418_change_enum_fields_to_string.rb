class ChangeEnumFieldsToString < ActiveRecord::Migration
  def self.up
    change_column(:clicks, :click_type, :string, :null => false, :default => "product_email_link")
    change_column(:email_day_preferences, :day_of_week, :string, :null => false)
    change_column(:sales, :sale_type, :string, :null => false, :default => "sale")
    change_column(:user_invites, :state, :string, :null => false, :default => "pending")
    change_column(:users, :state, :string, :null => false, :default => "pending")
  end

  def self.down
  end
end
