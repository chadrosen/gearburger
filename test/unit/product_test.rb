require 'test_helper'
require 'product_generator'

class ProductTest < ActiveSupport::TestCase
    
  def setup
    @pg = AlertGenerator::ProductGenerator.new
    @f = FeedCategory.find(:first, :conditions => ["category_id is not null"])
  end
        
  def test_product_changes_no_changes
    changes = Product.get_changed_products()
    assert_equal changes.length, 0
  end

  def test_product_changes_with_sale
    p1 = @pg.create_product(@f.id, "sku", "product name", "whoopi", "doodoo", "boingboing", "bababooie", 100.0, :sale_price => 90.0)
    
    update_products([p1], @f)
    
    changes = Product.get_changed_products()
    assert_equal changes.length, 1
  end

  def test_product_changes_with_no_sale
    f = FeedCategory.find(:first)
    @pg.create_product(f.id, "sku", "product name", "whoopi", "doodoo", "boingboing", "bababooie", 100.0, :sale_price => 100.0)
    changes = Product.get_changed_products()
    assert_equal changes.length, 0
  end

  def test_product_changes_within_threshold
    p1 = @pg.create_product(@f.id, "sku", "product name", "whoopi", "doodoo", "boingboing", "bababooie", 100.0, :sale_price => 75.0)
    
    update_products([p1], @f)
    
    changes = Product.get_changed_products(:threshold => 0.2)
    assert_equal changes.length, 1
  end

  def test_product_changes_outside_threshold
    f = FeedCategory.find(:first)
    @pg.create_product(f.id, "sku", "product name", "whoopi", "doodoo", "boingboing", "bababooie", 100.0, 
      :sale_price => 90.0)
    changes = Product.get_changed_products(:threshold => 0.2)
    assert_equal changes.length, 0
  end

  def test_product_changes_sale_worse_than_previous
    f = FeedCategory.find(:first)
    @pg.create_product(f.id, "sku", "product name", "whoopi", "doodoo", "boingboing", "bababooie", 100.0, 
      :sale_price => 90.0)
    @pg.create_product(f.id, "sku", "product name", "whoopi", "doodoo", "boingboing", "bababooie", 
      100.0, :sale_price => 95.0)
    changes = Product.get_changed_products()
    assert_equal changes.length, 0
  end

  def test_product_changes_for_old_product
    t = Time.zone.now - 100000
    f = FeedCategory.find(:first)
    @pg.create_product(f.id, "sku", "product name", "whoopi", "doodoo", "boingboing", "bababooie", 100.0, :sale_price => 90.0, :created_at => t)   
    changes = Product.get_changed_products()
    assert_equal changes.length, 0
  end

  def test_product_changes_multiple_matches
    p1 = @pg.create_product(@f.id, "sku", "product name", "whoopi", "doodoo", "boingboing", "bababooie", 100.0, :sale_price => 90.0)
    p2 = @pg.create_product(@f.id, "sku2", "product name 2", "whoopi", "doodoo", "boingboing", "bababooie", 100.0, :sale_price => 90.0)

    update_products([p1, p2], @f)
    
    changes = Product.get_changed_products()
    assert_equal changes.length, 2
  end

  def test_multiple_matches_doesnt_exceed_limit
    f = FeedCategory.find(:first)
    p1 = @pg.create_product(f.id, "sku", "product name", "whoopi", "doodoo", "boingboing", "bababooie", 100.0, :sale_price => 90.0)
    p2 = @pg.create_product(f.id, "sku2", "product name 2", "whoopi", "doodoo", "boingboing", "bababooie", 100.0, :sale_price => 90.0)
    
    update_products([p1, p2], @f)
    
    changes = Product.get_changed_products(:limit => 1)
    assert_equal changes.length, 1
  end

  def test_ordering_of_sales_percent
    f = FeedCategory.find(:first)
    p1 = @pg.create_product(f.id, "sku", "product name", "whoopi", "doodoo", "boingboing", "bababooie", 100.0, :sale_price => 90.0)
    p2 = @pg.create_product(f.id, "sku2", "product name 2", "whoopi", "doodoo", "boingboing", "bababooie", 10.0, :sale_price => 5.0)

    update_products([p1, p2], @f)

    changes = Product.get_changed_products()
    assert_equal changes[0].sku, "sku2"
  end

  def test_offset
    f = FeedCategory.find(:first)
    p1 = @pg.create_product(@f.id, "sku", "product name", "whoopi", "doodoo", "boingboing", "bababooie", 100.0, :sale_price => 90.0)
    p2 = @pg.create_product(@f.id, "sku2", "product name 2", "whoopi", "doodoo", "boingboing", "bababooie", 10.0, :sale_price => 5.0)

    update_products([p1, p2], @f)

    changes = Product.get_changed_products(:offset => 1, :limit => 1)
    assert_not_nil changes
    assert !changes.empty?
    assert_equal changes.length, 1
    assert_equal changes[0].sku, "sku"
  end

protected

  def update_products(ps, f)
    # I think the default create_product method is associating the products incorrectly...
    # The hack is to create them and then change their feed_category. This method makes it shorter
    ps.each { |p| p.feed_category = f; p.save! }
  end
  
end
