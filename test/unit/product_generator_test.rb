require 'yaml'
require File.dirname(__FILE__) + '/../test_helper'
require 'product_generator'

class ProductGeneratorTest < ActiveSupport::TestCase

  fixtures :products, :brands, :categories, :departments, :users, :feeds
                
  def setup
    @pg = AlertGenerator::ProductGenerator.new    
  end
        
  def test_exact_match
    assert @pg.get_department("men", "blah", "blah", "blah")
  end
  
  def test_spaces_match
    assert @pg.get_department("   men   ", "blah", "blah", "blah")    
  end
  
  def test_case_match
    assert @pg.get_department("Men", "blah", "blah", "blah")
    assert @pg.get_department("MeN", "blah", "blah", "blah")
    assert @pg.get_department("MEN", "blah", "blah", "blah")  
  end
  
  def test_combined_word_match
    assert_not_equal @pg.get_department("women", "blah", "blah", "blah").value, 'men'
    assert !@pg.get_department("menmenmen", "blah", "blah", "blah")
    assert !@pg.get_department("fomen", "blah", "blah", "blah")
  end
  
  def test_beginning_of_line
    assert @pg.get_department("men are the best", "blah", "blah", "blah")
  end
  
  def test_end_of_line
    assert @pg.get_department("I do not like men", "blah", "blah", "blah")
  end
  
  def test_in_middle_of_line
    assert @pg.get_department("watch out for crazy men on the street", "blah", "blah", "blah")
  end

  def test_department_match
    # Should return men
    assert_nil @pg.get_department(products(:product_one)[:product_name], "blah", "blah", "blah")
    
    assert_equal "women", @pg.get_department(products(:product_two)[:product_name], "blah", "blah", "blah").value
    assert_equal "kid", @pg.get_department(products(:product_three)[:product_name], "blah", "blah", "blah").value
    assert_equal "men", @pg.get_department(products(:product_four)[:product_name], "blah", "blah", "blah").value
  end
  
  def test_department_no_match  
    # no deparment in this title
    assert_nil @pg.get_department(products(:product_one)[:product_name], "blah", "blah", "blah")
    assert_not_equal "men", @pg.get_department(products(:product_two)[:product_name], "blah", "blah", "blah").value
    assert_not_equal "women", @pg.get_department(products(:product_four)[:product_name], "blah", "blah", "blah").value
  end
  
  def test_process_feed_line
    # Send in a custom header and a row of data and get a product
        
    # Get the column mapping from the header
    pg = AlertGenerator::AvantlinkFeedParser.new(Feed.find(:first))
    header = AlertGenerator::AvantlinkFeedParser::RequiredColumns
    column_mapping = pg.map_header(header)
    row = ["a", "b", "c", "d", 10.0].join(",")
    assert_not_nil pg.create_product_from_csv_line(row)
  end
  
  def test_auto_header_no_data
    pg = AlertGenerator::AvantlinkFeedParser.new(feeds(:dogfunk), :limit => 10)
    assert_raises (NameError) do 
      pg.map_header([])
      pg.map_header
      pg.map_header({})
      pg.map_header("")
    end
  end
  
  def test_auto_header_with_missing_required_data
    # Missing required fields
    pg = AlertGenerator::AvantlinkFeedParser.new(feeds(:dogfunk), :limit => 10)
    assert_raises (NameError) do
      columns = pg.map_header(["sku", "brand name", "product name"])
    end
  end
  
  def test_auto_header_with_valid_data_in_correct_order
    pg = AlertGenerator::AvantlinkFeedParser.new(feeds(:dogfunk))
    columns = pg.map_header(AlertGenerator::AvantlinkFeedParser::RequiredColumns)
        
    assert_equal pg.column_mapping[AlertGenerator::AvantlinkFeedParser::Sku], 0
    assert_equal pg.column_mapping[AlertGenerator::AvantlinkFeedParser::BrandName], 1
    assert_equal pg.column_mapping[AlertGenerator::AvantlinkFeedParser::ProductName], 2
  end  
  
  def test_auto_header_different_ordered_data

    pg = AlertGenerator::AvantlinkFeedParser.new(feeds(:dogfunk))
    pg.map_header([
      AlertGenerator::AvantlinkFeedParser::RetailPrice, 
      AlertGenerator::AvantlinkFeedParser::Category, 
      AlertGenerator::AvantlinkFeedParser::BrandName,
      AlertGenerator::AvantlinkFeedParser::ProductName,
      AlertGenerator::AvantlinkFeedParser::Sku
    ])
    
    assert_equal pg.column_mapping[AlertGenerator::AvantlinkFeedParser::Sku], 4
    assert_equal pg.column_mapping[AlertGenerator::AvantlinkFeedParser::BrandName], 2
    
  end
  
  def test_process_full_feed

    # Let's blow away existing data before we start..
    Product.delete_all
    ProductGenerationSummary.delete_all

    pg = AlertGenerator::AvantlinkFeedParser.new(feeds(:dogfunk), :limit => 10)
    f = File.join(Rails.root.to_s, "test", "unit", "full_feed.gz")
    pgs = pg.process_product_feed(f)
    
    # Test the summary info..
    assert_equal [0, 10, 0, 10], [pgs.product_errors, pgs.new_products, pgs.product_updates, Product.count]
  end
  
  def test_get_brand_exists
    assert brands(:Asolo)
    assert @pg.get_brand(brands(:Asolo).name)
  end
    
  def test_get_feed_category_exists
    fc = feed_categories(:pants)
    assert fc
    assert @pg.get_feed_category(feeds(:backcountry), fc.feed_category, fc.feed_subcategory, fc.feed_product_group)
  end
  
  def test_create_new_product
    product = @pg.create_product(1, "abc", "defg", "chadco", "baskethole", "woot", "waht", 1.0)
    assert_not_nil product
    assert_equal product.sku, "abc"
    assert_equal product.product_name, "defg"
    assert_equal product.brand.name, "chadco"    
    assert_equal product.feed_category.feed_category, "baskethole"
    assert_equal product.feed_category.feed_subcategory, "woot"
    assert_equal product.feed_category.feed_product_group, "waht"    
    assert_nil product.department
  end

  def test_no_match_across_feeds
    p1 = @pg.create_product(1, "abc", "defg", "chadco", "baskethole", "woot", "waht", 1.0)
    assert_not_nil p1
    p2 = @pg.create_product(2, "abc", "defg", "chadco", "baskethole", "woot", "waht", 1.0)
    assert_not_equal p1.id, p2.id
  end

  def test_no_match_across_sku
    p1 = @pg.create_product(1, "abc", "defg", "chadco", "baskethole", "woot", "waht", 1.0)
    assert_not_nil p1
    p2 = @pg.create_product(1, "abcd", "defg", "chadco", "baskethole", "woot", "waht", 1.0)
    assert_not_equal p1.id, p2.id
  end
  
  def test_edit_existing_product
    p1 = @pg.create_product(1, "abc", "defg", "chadco", "baskethole", "woot", "waht", 1.0)
    assert_not_nil p1
    p2 = @pg.create_product(1, "abc", "defg", "chadco", "baskethole", "woot", "waht", 1.0)
    # Sanity test..
    assert_equal p1.id, p2.id
    assert_equal p2.sku, "abc"
    assert_equal p2.product_name, "defg"
    assert_equal p2.brand.name, "chadco"    
    assert_equal p2.feed_category.feed_category, "baskethole"
    assert_equal p2.feed_category.feed_subcategory, "woot"
    assert_equal p2.feed_category.feed_product_group, "waht"
    assert_nil p2.department
  end
  
  def test_prices_on_new_record
    product = @pg.create_product(1, "abc", "defg", "chadco", "baskethole", "woot", "waht", 10.0, 
      :sale_price => 10.0)
    assert_not_nil product
    
    # Sanity
    assert_equal product.retail_price, "10.0".to_d
    assert_equal product.sale_price, "10.0".to_d
    
    # Product price info
    assert_equal product.product_prices.length, 1 # There should only be one record
    assert_equal product.product_prices[0].price, "10.0".to_d
    
    # New products are always marked as new product price changes
    assert product.price_changed_at, Date.today
  end
  
  def test_edit_sale_price_no_change
    
    assert_equal @pg.stats[:price_changes], 0
    
    product = @pg.create_product(1, "abc", "defg", "chadco", "baskethole", "woot", "waht", 10.0, 
      :sale_price => 10.0)
    assert_not_nil product
    
    p2 = @pg.create_product(1, "abc", "defg", "chadco", "baskethole", "woot", "waht", 10.0, 
      :sale_price => 10.0)
    
    # Sanity
    assert_equal p2.retail_price, "10.0".to_d
    assert_equal p2.sale_price, "10.0".to_d
    
    # Product prices
    assert_equal product.product_prices.length, 1 # There should still only be one record
    assert_equal product.product_prices[0].price, "10.0".to_d
    
    assert_equal @pg.stats[:price_changes], 0
  end
  
  def test_edit_sale_price_with_change
    
    assert_equal @pg.stats[:price_changes], 0
    
    product = @pg.create_product(1, "abc", "defg", "chadco", "baskethole", "woot", "waht", 10.0, 
      :sale_price => 10.0, :created_at => Date.today - 1)
    assert_not_nil product
    
    p2 = @pg.create_product(1, "abc", "defg", "chadco", "baskethole", "woot", "waht", 10.0, 
      :sale_price => 9.0, :created_at => Date.today)
    
    # Sanity
    assert_equal p2.retail_price, "10.0".to_d
    assert_equal p2.sale_price, "9.0".to_d
    
    # Product prices
    assert_equal p2.product_prices.length, 2 # There should be two records now
    assert_equal p2.product_prices[0].price, "10.0".to_d
    assert_equal p2.product_prices[1].price, "9.0".to_d    
    
    assert_equal @pg.stats[:price_changes], 1
    
  end
  
  def test_price_false_after_update
    
    # Create the product. It's initially marked as having a price change
    t = Time.zone.now
    product = @pg.create_product(1, "abc", "defg", "chadco", "baskethole", "woot", "waht", 10.0, 
      :sale_price => 10.0, :created_at => t)
    assert_not_nil product
    assert_equal product.price_changed_at, t
      
    # Create the same product with the same sales price.. 
    p2 = @pg.create_product(1, "abc", "defg", "chadco", "baskethole", "woot", "waht", 10.0, 
      :sale_price => 10.0, :created_at => Time.zone.now)

    # Should be marked as not having a price change
    assert_not_nil p2
    assert_equal product.id, p2.id
    assert_equal p2.price_changed_at.to_i, t.to_i
  end
  
  def test_price_true_after_price_update
    # Create the product. It's initially marked as having a price change
    p1 = @pg.create_product(1, "abc", "defg", "chadco", "baskethole", "woot", "waht", 10.0, 
      :sale_price => 10.0, :created_at => Date.today - 2)
        
    # Create the same product with the same sales price, gets marked as no change
    p2 = @pg.create_product(1, "abc", "defg", "chadco", "baskethole", "woot", "waht", 10.0, 
      :sale_price => 10.0, :created_at => Date.today - 1)
            
    # Updating the product the 3rd time marks the price as changed
    p3 = @pg.create_product(1, "abc", "defg", "chadco", "baskethole", "woot", "waht", 10.0, 
      :sale_price => 9.5, :created_at => Date.today)
            
    assert_not_nil p3
    assert p3.price_changed_at, Date.today
    assert_equal p3.product_prices.length, 2
  end
  
  def test_product_same_day_update
    # Create the product
    p1 = @pg.create_product(1, "qqq", "defg", "chadco", "baskethole", "woot", "waht", 10.0, 
      :sale_price => 10.0, :created_at => DateTime.now)
          
    # Create the same product on the same day
    t2 = Time.zone.now
    p2 = @pg.create_product(1, "qqq", "defg", "chadco", "baskethole", "woot", "waht", 9.0, 
      :sale_price => 9.0, :created_at => t2)

    # The second update is actually ignored
    p = Product.find_by_sku("qqq")
        
    assert_not_nil p
    assert_equal p.price_changed_at.to_i, t2.to_i
    assert_equal p.product_prices.length, 2
    assert_equal p.sale_price, 9.0.to_d
  end 
  
  def test_with_brand_mapping
        
    # Create the mapping. Asolo is mapped to asiago
    asolo = brands(:Asolo)
    asiago = brands(:Asiago)
    
    asolo.mapped_to = asiago
    asolo.save!
    
    assert_equal asolo.mapped_to, asiago
        
    pg = AlertGenerator::ProductGenerator.new
    product = pg.create_product(1, "abc", "defg", asolo.name, "baskethole", "woot", "waht", 10.0)
    assert_equal product.brand, asiago
  end   
  
  def test_brand_mapping_inactive_brand
    
    # Create the mapping. Asolo is mapped to asiago
    asolo = brands(:Asolo)
    asiago = brands(:Asiago)
    
    asolo.mapped_to = asiago
    asolo.active = false
    asolo.save!
    
    assert_equal asolo.mapped_to, asiago
        
    pg = AlertGenerator::ProductGenerator.new
    product = pg.create_product(1, "abc", "defg", asolo.name, "baskethole", "woot", "waht", 10.0, 
      :sale_price => 10.0)
    
    assert_not_nil product
    assert_equal product.brand, asiago
  end
    
      
protected
  
  def get_product_feed(name)
    path = File.dirname(__FILE__) + '/product_feeds.yml' 
    feed_yaml = YAML.load_file(path)
    return feed_yaml[name]
  end
  
  def get_full_feed()
    path = File.join(Rails.root.to_s, "test", "unit", "full_feed.csv")
    return File.open(path)
  end
  
  def get_full_feed_array()
    # Return the full feed as an array skipping the first line
    f = self.get_full_feed()
    a = f.readlines()
    return a[1..a.length]
  end
    
end
