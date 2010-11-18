class DefaultPopularBrands < ActiveRecord::Migration
  def self.up
    # Update popular brands with the current most popular brands
    Brand.popular_brands(:limit => 10).each { |b| b.update_attribute(:popular, true) }
  end

  def self.down
  end
end
