class AddCategoryPermalink < ActiveRecord::Migration
  def self.up
    add_column(:categories, :permalink, :string, :null => false)
    # Update the records
    Category.reset_column_information
    Category.find(:all).each { |c| c.update_attributes!(:permalink => PermalinkFu::escape(c.name)) }
    
  end

  def self.down
    remove_column(:categories, :permalink)
  end
end
