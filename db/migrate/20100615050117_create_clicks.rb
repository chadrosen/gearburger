class CreateClicks < ActiveRecord::Migration
  def self.up
    create_table :clicks, :id => false do |t|
      t.date :date, :null => false
      t.integer :alert_link, :null => false, :default => 0
      t.integer :product_link, :null => false, :default => 0
      t.integer :search_link, :null => false, :default => 0
    end
    add_index(:clicks, :date, :unique => true)
  end

  def self.down
    drop_table :clicks
  end
end
