class AddFeedCategoryColumns < ActiveRecord::Migration
  def self.up
    remove_index(:feed_categories, :feed_id_and_name)

    rename_column(:feed_categories, :name, :feed_category)
    add_column(:feed_categories, :feed_subcategory, :string, :null => true)
    add_column(:feed_categories, :feed_product_group, :string, :null => true)

    add_index(:feed_categories, [:feed_id, :feed_category, :feed_subcategory, :feed_product_group], 
              :name => :feed_category_index, :unique => true)
    FeedCategory.reset_column_information
  end

  def self.down
  end
end
