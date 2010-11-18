require 'test_helper'
require 'sales_processor'

class SaleTest < ActiveSupport::TestCase
  
  fixtures :users
  
  def setup
    @s = AlertGenerator::SalesProcessor.new
  end
  
  def test_new_sale
  end
  
  def test_with_existing_sale
  end

  def test_user
    #r = [0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    #@s.process_row(r)
  end
  
  def test_no_user
  end
  
  def test_no_click
  end
  
  def test_with_click
  end
  
  def test_with_cookie
  end

end
