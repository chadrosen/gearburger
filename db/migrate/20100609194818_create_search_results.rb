class CreateSearchResults < ActiveRecord::Migration
  def self.up
    create_table :search_results do |t|
      t.string :query, :null => false
      t.integer :user_id, :null => true
      t.datetime :created_at, :null => false
    end
    
    add_index(:search_results, :created_at)
  end

  def self.down
    drop_table :search_results
  end
end
