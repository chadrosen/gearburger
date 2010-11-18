class CreateFeedCategories < ActiveRecord::Migration
  def self.up
    create_table :feed_categories do |t|
      t.column :name, :string, :null => false
      t.column :feed_id, :integer, :null => false
      t.column :category_id, :integer, :null => true, :default => nil
      t.timestamps
      t.boolean  :active, :default => true, :null => false
      t.string   :value, :null => false     
    end
    
    add_index(:feed_categories, [:feed_id, :name], :unique => true)
    add_index(:feed_categories, :category_id)

    Product.delete_all()
    ProductPrice.delete_all()
    ProductGenerationSummary.delete_all()

    add_column(:products, :feed_id, :integer, :null => false)
    remove_index(:products, :sku)
    add_index(:products, [:feed_id, :sku], :unique => true)
    
    remove_index(:products, :category_id)
    remove_column(:products, :category_id)
    add_column(:products, :feed_category_id, :integer, :null => false)
    add_index(:products, :feed_category_id)

  end

  def self.down
    drop_table :feed_categories
  end
end
