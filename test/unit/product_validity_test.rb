require 'test_helper'
require 'product_validity'

class ProductValidityTest < ActiveSupport::TestCase
  
  def setup
    @p = ProductValidity::VerifyProduct.new
  end
    
  def test_empty_image_url
    assert !@p.validate_image("")
    assert !@p.validate_image(nil)
  end
  
  def test_invalid_image_url
    assert !@p.validate_image("asdfs")
    assert !@p.validate_image("www.foo.com")
  end
  
  def test_invalid_image_suffix
    assert !@p.validate_image("http://www.foo.com")
    assert !@p.validate_image("http://www.foo.html")        
  end
  
  def test_valid_image_url
    assert @p.validate_image("http://www.foo.com/foo.png")
    assert @p.validate_image("http://www.foo.com/foo.gif")
    assert @p.validate_image("http://www.foo.com/foo.jpg")
    
    # Case shouldn't matter
    assert @p.validate_image("http://www.foo.com/foo.PNG")
    assert @p.validate_image("http://www.foo.com/foo.GIF")
    assert @p.validate_image("http://www.foo.com/foo.JPG")
  end
  
  def test_html_for_price    
    assert @p.validate_sale_price("$35.89", "35.89".to_d)
    assert @p.validate_sale_price("   35.89   ", "35.89".to_d)
    assert @p.validate_sale_price("chad chad $35.89 foo foo", "35.89".to_d)
    assert @p.validate_sale_price("35.89 chad foo foo", "35.89".to_d)
    assert @p.validate_sale_price("chad chad $35.89", "35.89".to_d)
    assert @p.validate_sale_price("<html><body>chad chad <a href='foo'>$35.89</a> foo foo", "35.89".to_d)
  end
  
  def test_html_with_no_price
    assert !@p.validate_sale_price("chad chad $335.89", "35.89".to_d)
    assert !@p.validate_sale_price("chad chad $35.8922", "35.89".to_d)
    assert !@p.validate_sale_price("chad chad $5.89", "35.89".to_d)
    assert !@p.validate_sale_price("", "35.89".to_d)
  end
  
  def test_no_hundredth_price
    assert @p.validate_sale_price("chad chad 335.90 foo foo", "335.90".to_d)
    assert @p.validate_sale_price("chad chad 335.90 foo foo", "335.9".to_d)
    assert @p.validate_sale_price("chad chad 335.90 foo foo", "335.90000".to_d)
    assert @p.validate_sale_price("chad chad 335.90 foo foo", "335.90".to_d)
    assert @p.validate_sale_price("chad chad 5.90 foo foo", "5.90".to_d)
    assert @p.validate_sale_price("chad chad 0.90 foo foo", ".90".to_d)
    assert @p.validate_sale_price("chad chad 0.90 foo foo", "0.901111".to_d)
  end
  
end