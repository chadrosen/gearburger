require 'test_helper'
require 'product_feed_matcher'
require 'product_generator'

class CategoryArrayTest < ActiveSupport::TestCase

  fixtures :categories

  def setup
    @pg = AlertGenerator::ProductGenerator.new
    
    @t = Time.zone.now
    @c1 = categories(:shoes)
    @fc1 = @c1.feed_categories[0]
    @f1 = @fc1.feed
    @c2 = categories(:clothing)
    @fc2 = @c2.feed_categories[0]
    @f2 = @fc2.feed
    @pm = AlertGenerator::ProductFeedMatcher.new(:batch_wait => 0)

    # Remove all products
    Product.delete_all()

    @p1 = @pg.create_product(@f1.id, "sku", "product name", "blah", @fc1.feed_category, @fc1.feed_subcategory, 
                            @fc1.feed_product_group, 100.0, :sale_price => 90.0)
    @p2 = @pg.create_product(@f1.id, "sku", "product name2", "blah", @fc1.feed_category, @fc1.feed_subcategory, 
                            @fc1.feed_product_group, 10.0, :sale_price => 8.0) 
    @p3 = @pg.create_product(@f2.id, "sku", "product name3", "blah", @fc2.feed_category, @fc2.feed_subcategory, 
                            @fc2.feed_product_group, 10.0, :sale_price => 8.0)
  end

  def test_basic
    cats = @pm.make_category_array([@p1])

    category = cats[0][0]
    product_rows = cats[0][1]
    products = product_rows[0]

    assert_equal cats.length, 1
    assert_equal products.length, 1
    assert_equal Category.exists?(category), true
    assert_equal Product.exists?(products[0]), true
  end

  def test_multiple_products
    cats = @pm.make_category_array([@p1,@p2])
    category = cats[0][0]
    product_rows = cats[0][1]
    products = product_rows[0]

    assert_equal cats.length, 1
    assert_equal products.length, 2
    assert_equal Category.exists?(category), true
    assert_equal products[0].id, @p2.id
    assert_equal Product.exists?(products[0]), true
    assert_equal Product.exists?(products[1]), true
  end

  def test_multiple_categories
    cats = @pm.make_category_array([@p1,@p2,@p3])
    category = cats[0][0]
    product_rows = cats[0][1]
    products = product_rows[0]

    category2 = cats[1][0]
    product_rows2 = cats[1][1]
    products2 = product_rows2[0]    

    assert_equal cats.length, 2
    assert_equal products.length, 2
    assert_equal Category.exists?(category), true
    assert_equal Product.exists?(products[0]), true
    assert_equal Product.exists?(products[1]), true

    assert_equal products2.length, 1
    assert_equal Category.exists?(category2), true
    assert_equal Product.exists?(products2[0]), true    
  end

  def test_name_sort
    cats = @pm.make_category_array([@p1,@p2,@p3], :sort_by => :name)

    category = cats[0][0]
    product_rows = cats[0][1]
    products = product_rows[0]

    assert_equal products.length, 1
  end

  def test_number_sort
    cats = @pm.make_category_array([@p1,@p2,@p3], :sort_by => :number)

    category = cats[0][0]
    product_rows = cats[0][1]
    products = product_rows[0]

    assert_equal products.length, 2
  end  

  def test_limit
    cats = @pm.make_category_array([@p1,@p2,@p3], :limit => 1)

    category = cats[0][0]
    product_rows = cats[0][1]
    products = product_rows[0]

    category2 = cats[1][0]
    product_rows2 = cats[1][1]
    products2 = product_rows2[0]  

    assert_equal products.length, 1
    assert_equal products2.length, 1
  end 

  def test_limit_zero
    cats = @pm.make_category_array([@p1,@p2,@p3], :limit => 0)

    category = cats[0][0]
    product_rows = cats[0][1]
    products = product_rows[0]

    category2 = cats[1][0]
    product_rows2 = cats[1][1]
    products2 = product_rows2[0]    

    assert_equal products.length, 0
    assert_equal products2.length, 0
  end

  def test_limit_large
    cats = @pm.make_category_array([@p1,@p2,@p3], :limit => 10)

    category = cats[0][0]
    product_rows = cats[0][1]
    products = product_rows[0]

    category2 = cats[1][0]
    product_rows2 = cats[1][1]
    products2 = product_rows2[0]    

    assert_equal products.length, 2
    assert_equal products2.length, 1
  end  

  def test_group_by
    cats = @pm.make_category_array([@p1,@p2], :group_by => 1)

    category = cats[0][0]
    product_rows = cats[0][1]
    products1 = product_rows[0]
    products2 = product_rows[1]

    assert_equal product_rows.length, 2
    assert_equal products1.length, 1
    assert_equal products2.length, 1
  end

  def test_group_by_zero
    cats = @pm.make_category_array([@p1,@p2], :group_by => 0)

    category = cats[0][0]
    product_rows = cats[0][1]
    products = product_rows[0]

    assert_equal product_rows.length, 1
    assert_equal products.length, 0
  end

  def test_group_by_large
    cats = @pm.make_category_array([@p1,@p2], :group_by => 10)

    category = cats[0][0]
    product_rows = cats[0][1]
    products = product_rows[0]

    assert_equal product_rows.length, 1
    assert_equal products.length, 2
  end  

end
