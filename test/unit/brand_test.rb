require File.dirname(__FILE__) + '/../test_helper'
class BrandTest < ActiveSupport::TestCase

  fixtures :products, :brands, :categories, :departments, :users
                
  def setup
  end
  
  def test_brand_mapping
    # TODO: Probably should be on the brand_test
    
    b1 = brands(:six_eight_six)
    b2 = brands(:Asolo)
    
    assert_equal b1.users.length, 5
    assert_equal b2.users.length, 1
    assert_nil b1.mapped_to
      
    # Create the mapping. Asolo is mapped to asiago
    assert_equal b1.products.length, 5
    assert_equal b2.products.length, 0
        
    Brand.map_brand(b1, b2)

    # Reload the objects to test changes
    # TODO: Is there a way to make this happen automatically?
    b1 = Brand.find_by_name("686")
    b2 = Brand.find_by_name("Asolo")

    assert_equal b1.mapped_to, b2    
    assert_equal b1.products.length, 0
    assert_equal b2.products.length, 5
    assert_equal b1.users.length, 0
    assert_equal b2.users.length, 6
    assert_equal b1.active, false
  end
  
  def test_mapping_same_brand_to_itself
    b1 = brands(:six_eight_six)
    b2 = brands(:six_eight_six)
    
    assert_nil b1.mapped_to
    assert_nil b2.mapped_to
    
    Brand.map_brand(b1, b2)
    
    assert_nil b1.mapped_to
    assert_nil b2.mapped_to
    assert_equal b1.active, true
    assert_equal b2.active, true
  end
  
  def test_circular_brand_mapping_reference_doesnt_work
    
    b1 = brands(:six_eight_six)
    b2 = brands(:Asolo)
    
    Brand.map_brand(b1, b2)
    assert_equal b1.mapped_to, b2
    assert_equal b2.mapped_to_me[0], b1
    
    # Now try to create a circular reference
    b1 = brands(:six_eight_six)
    b2 = brands(:Asolo)
    Brand.map_brand(b2, b1)
    assert_equal b1.mapped_to, b2
    assert_equal b2.mapped_to_me[0], b1
    assert_nil b2.mapped_to
    
  end
    
end
