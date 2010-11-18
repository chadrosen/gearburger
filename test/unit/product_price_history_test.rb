require 'test_helper'
require 'product_generator'

class ProductPriceHistoryTest < ActiveSupport::TestCase
    
  def setup
    @pg = AlertGenerator::ProductGenerator.new
    @f = FeedCategory.find(:first, :conditions => ["category_id is not null"])
  end

  def test_one_price_change
    price = 90.0
    p = @pg.create_product(@f.feed_id, "sku", "product name", "whoopi", "doodoo", "boingboing", "bababooie", 100.0, :sale_price => price)
    p.populate_price_history

    assert_equal price, p.min_price
    assert_equal price, p.max_price
    assert_equal price, p.avg_price
  end

  def test_two_price_changes_min
    price = 90.0
    price2 = 80.0
    p = @pg.create_product(@f.feed_id, "sku", "product name", "whoopi", "doodoo", "boingboing", "bababooie", 100.0, :sale_price => price)
    ProductPrice.create(:product_id => p.id, :created_at => Time.zone.now - 1.days, :price => price2)
    p.populate_price_history

    assert_equal price2, p.min_price
    assert_equal price, p.max_price
    assert_in_delta price2, p.avg_price, 1.0
  end
 
  def test_two_price_changes_max
    price = 90.0
    price2 = 100.0
    p = @pg.create_product(@f.feed_id, "sku", "product name", "whoopi", "doodoo", "boingboing", "bababooie", 100.0, :sale_price => price)
    ProductPrice.create(:product_id => p.id, :created_at => Time.zone.now - 1.days, :price => price2)
    p.populate_price_history

    assert_equal price, p.min_price
    assert_equal price2, p.max_price
    assert_in_delta price2, p.avg_price, 1.0
  end

end
