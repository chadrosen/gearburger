require 'test_helper'
require 'social_alerts'

class SocialAlertsTest < ActiveSupport::TestCase

  fixtures :brands
  
  def setup
    @ppca = AlertGenerator::ProductPriceChangeAlert.new
  end
  
  def test_message_one_product
    msg = @ppca.get_message(1, 1, [brands(:Asiago).name])
    assert_equal msg, "1 new deal from Asiago http://www.gearburger.com"
  end

  def test_message_two_products_one_brand
    msg = @ppca.get_message(2, 1, [brands(:Asiago).name])
    assert_equal msg, "2 new deals from Asiago http://www.gearburger.com"    
  end

  def test_two_products_two_brands
    msg = @ppca.get_message(2, 2, [brands(:Asiago).name, brands(:MPG).name])
    assert_equal msg, "2 new deals from Asiago, MPG http://www.gearburger.com"        
  end

  def test_more_brands_than_slices
    msg = @ppca.get_message(2, 10, [brands(:Asiago).name, brands(:MPG).name])
    assert_equal msg, "2 new deals from Asiago, MPG and 8 other brands http://www.gearburger.com"    
  end
  
  def test_one_more_brand_than_limit
    msg = @ppca.get_message(2, 4, [brands(:Asiago).name, brands(:MPG).name, brands(:Ancestor).name])
    assert_equal msg, "2 new deals from Asiago, MPG, Ancestor and 1 other brand http://www.gearburger.com"    
  end 
  
  def test_multi_brands_greater_than_limit
    msg = @ppca.get_message(2, 10, [brands(:Asiago).name, brands(:MPG).name, brands(:Ancestor).name])
    assert_equal msg, "2 new deals from Asiago, MPG, Ancestor and 7 other brands http://www.gearburger.com"    
  end 
  
end