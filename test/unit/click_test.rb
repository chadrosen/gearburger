require 'test_helper'

class ClickTest < ActiveSupport::TestCase

  fixtures :users

  def setup
    # Clean up fixtures before test..
    Click.delete_all
  end

  def test_two_clicks
    c1 = Click.track!(users(:chad), "product_email_link")
    c2 = Click.track!(users(:chad), "product_email_link")
    
    assert_equal Click.count, 2
  end
    
end
