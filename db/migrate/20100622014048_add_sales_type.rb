class AddSalesType < ActiveRecord::Migration
  def self.up
    add_column(:sales, :sale_type, :enum, :limit => [:sale, :adjustment], :default => :sale)
  end

  def self.down
    remove_column(:sales, :sale_type)
  end
end
