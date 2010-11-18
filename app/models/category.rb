class Category < ActiveRecord::Base
  
  # A user can have many categories
  has_many :categories_users
  has_many :users, :through => :categories_users
  
  # A product has a feed_category. Each category has many feed_categories.
  # Each category has many products through the feed category table
  has_many :feed_categories  
  has_many :products, :through => :feed_categories

  validates_presence_of :name
  validates_inclusion_of :active, :in => [true, false]
  validates_uniqueness_of :name

  # Attribute to dynamically store average price
  attr_accessor :average_discount

  def populate_average_discount
    self.average_discount = self.products.average('(retail_price - sale_price) / retail_price')
  end
  
end
