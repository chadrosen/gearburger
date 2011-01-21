require 'test_helper'
require 'product_validity'

class ProductValidityTest < ActiveSupport::TestCase
  
  fixtures :products
  
  def setup
    @p = ProductValidity::VerifyProduct.new
  end
    
  def test_empty_image_url
    assert_equal false, @p.validate_image("")[:success]
    assert_equal false, @p.validate_image(nil)[:success]
  end
  
  def test_invalid_image_url
    assert_equal false, @p.validate_image("asdfs")[:success]
    assert_equal false, @p.validate_image("www.foo.com")[:success]
  end
  
  def test_invalid_image_suffix
    assert_equal false, @p.validate_image("http://www.foo.com")[:success]
    assert_equal false, @p.validate_image("http://www.foo.html")[:success]
  end
  
  def test_valid_image_url
    assert @p.validate_image("http://www.foo.com/foo.png")[:success]
    assert @p.validate_image("http://www.foo.com/foo.gif")[:success]
    assert @p.validate_image("http://www.foo.com/foo.jpg")[:success]
    
    # Case shouldn't matter
    assert @p.validate_image("http://www.foo.com/foo.PNG")[:success]
    assert @p.validate_image("http://www.foo.com/foo.GIF")[:success]
    assert @p.validate_image("http://www.foo.com/foo.JPG")[:success]
  end
  
  def test_html_for_price    
    assert @p.validate_sale_price("$35.89", "35.89".to_d)[:success]
    assert @p.validate_sale_price("   35.89   ", "35.89".to_d)[:success]
    assert @p.validate_sale_price("chad chad $35.89 foo foo", "35.89".to_d)[:success]
    assert @p.validate_sale_price("35.89 chad foo foo", "35.89".to_d)[:success]
    assert @p.validate_sale_price("chad chad $35.89", "35.89".to_d)[:success]
    assert @p.validate_sale_price("<html><body>chad chad <a href='foo'>$35.89</a> foo foo", "35.89".to_d)[:success]
  end
  
  def test_html_with_no_price
    assert_equal false, @p.validate_sale_price("chad chad $335.89", "35.89".to_d)[:success]
    assert_equal false, @p.validate_sale_price("chad chad $35.8922", "35.89".to_d)[:success]
    assert_equal false, @p.validate_sale_price("chad chad $5.89", "35.89".to_d)[:success]
    assert_equal false, @p.validate_sale_price("", "35.89".to_d)[:success]
  end
  
  def test_no_hundredth_price
    assert @p.validate_sale_price("chad chad 335.90 foo foo", "335.90".to_d)[:success]
    assert @p.validate_sale_price("chad chad 335.90 foo foo", "335.9".to_d)[:success]
    assert @p.validate_sale_price("chad chad 335.90 foo foo", "335.90000".to_d)[:success]
    assert @p.validate_sale_price("chad chad 335.90 foo foo", "335.90".to_d)[:success]
    assert @p.validate_sale_price("chad chad 5.90 foo foo", "5.90".to_d)[:success]
    assert @p.validate_sale_price("chad chad 0.90 foo foo", ".90".to_d)[:success]
    assert @p.validate_sale_price("chad chad 0.90 foo foo", "0.901111".to_d)[:success]
  end
  
  def test_valid_product
    
    p = products(:product_two)
    assert_equal true, p.valid_small_image
    assert_equal true, p.valid_sale_price
    @p.validate_product!(p)
    
    p2 = Product.find(p.id)
    assert_equal true, p.valid_small_image
    assert_equal true, p.valid_sale_price    
  end
  
end