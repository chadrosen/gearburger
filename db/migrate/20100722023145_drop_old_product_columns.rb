class DropOldProductColumns < ActiveRecord::Migration
  def self.up
    remove_column(:products, :keywords)
    remove_columns(:products, :short_description)
  end

  def self.down
  end
end
