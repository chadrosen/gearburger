class ProductGenerationSummary < ActiveRecord::Base

  validates_numericality_of :new_products, :only_integer => true
  validates_numericality_of :product_updates, :only_integer => true
  validates_numericality_of :new_cats, :only_integer => true
  validates_numericality_of :new_brands, :only_integer => true
  validates_numericality_of :product_errors, :only_integer => true
  validates_presence_of :feed_id
  
  belongs_to :feed
end
