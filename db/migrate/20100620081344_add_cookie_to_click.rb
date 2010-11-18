class AddCookieToClick < ActiveRecord::Migration
  def self.up
    # In case the user isn't logged in but we have their abingo cookie
    add_column(:clicks, :cookie, :string, :null => true)    
  end

  def self.down
    remove_column(:clicks, :cookie)
  end
end
