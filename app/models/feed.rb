class Feed < ActiveRecord::Base
  has_many :product_generation_summaries  
  has_many :products
  has_many :feed_categories
  
  has_one :most_recent_run, :class_name => 'ProductGenerationSummary', :order => 'id DESC'

  validates_presence_of :name  
end
