class RemoveUnusedTables < ActiveRecord::Migration
  def self.up
    # Simplify app by removing functionality
    drop_table(:product_prices)
    drop_table(:alternatives)
    drop_table(:experiments)
  end

  def self.down
  end
end
