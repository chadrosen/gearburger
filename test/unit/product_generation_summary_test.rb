require 'test_helper'

class ProductGenerationSummaryTest < ActiveSupport::TestCase
  
  def test_default_creation
    ProductGenerationSummary.create(:feed_id => "BC outlet")      
    assert_equal ProductGenerationSummary.count, 1
  end
  
  def test_simple_creation
    ProductGenerationSummary.create(:feed_id => "BC outlet", :new_products => 1,
      :product_updates => 1, :new_cats => 1, :new_brands => 1,
      :product_errors => 1)
    assert_equal ProductGenerationSummary.count, 1          
  end
  
end
