class ClickLog < ActiveRecord::Migration
  def self.up
    drop_table(:clicks)
    create_table :clicks do |t|
      t.enum :click_type, :limit => [:alert_link, :product_link, :search_link], :null => false
      t.integer :user_id, :null => true
      t.datetime :created_at, :null => false
    end
    
    add_index(:clicks, [:created_at, :click_type])    
  end
    
  def self.down
    drop_table(:clicks)
  end
end
