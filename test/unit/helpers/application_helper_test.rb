require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  
  def test_get_price_percentage_whole_floats
    assert_equal 50.00, get_price_percentage(100, 50)
    assert_equal 0.00, get_price_percentage(100, 100)
    assert_equal 50.00, get_price_percentage(100.00, 50.00)
  end
  
  def test_rounded_floats
    assert_equal 51.00, get_price_percentage(100.50, 50)
    assert_equal 51.00, get_price_percentage(100.01, 50)
    assert_equal 0.00, get_price_percentage(100.00, 100.00)    
  end
    
  def test_get_price_percentage_string
    assert_equal 50.00, get_price_percentage_string("100", "50")
    assert_equal 50.00, get_price_percentage_string("$100", "50")      
    assert_equal 50.00, get_price_percentage_string("100", "$50")
    assert_equal 50.00, get_price_percentage_string("$100", "$50")
    assert_equal 50.00, get_price_percentage_string("$100.00", "$50.00")    
    assert_equal 51.00, get_price_percentage_string("$100.50", "$50.00")
  end
  
  
end
