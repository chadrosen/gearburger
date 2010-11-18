class RemoveOldTables < ActiveRecord::Migration
  def self.up
    drop_table(:blocked_products)
    drop_table(:captions)
    drop_table(:contests)
    drop_table(:coupons)
  end

  def self.down
  end
end
