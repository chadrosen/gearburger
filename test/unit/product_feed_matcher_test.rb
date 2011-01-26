require 'test_helper'
require 'product_feed_matcher'
require 'product_generator'

class ProductFeedMatcherTest < ActiveSupport::TestCase

  fixtures :users, :departments, :brands, :categories, :feed_categories

  def setup
    @pg = AlertGenerator::ProductGenerator.new
    
    @t = Time.zone.now
    @u = users(:chad)
    @b = brands(:six_eight_six)
    @c = categories(:clothing)
    @fc = feed_categories(:shirts)
    @pm = AlertGenerator::ProductFeedMatcher.new(:batch_wait => 0)
  end

  def teardown
    ActionMailer::Base.deliveries = []    
  end

  def test_price_matching_no_matches
    matches = users(:chad).matching_products    
    assert_equal 0, matches.length
  end
  
  def test_price_match_new_product_with_sale        
    # Create a product that I know the user has
    @pg.create_product(@fc.feed_id, "sku", "product name", @b.name, @fc.feed_category, @fc.feed_subcategory, 
      @fc.feed_product_group, 100.0, :sale_price => 90.0)
    
    matches = @u.matching_products
    assert_equal 1, matches.length
  end
  
  def test_price_match_new_product_with_no_sale

    @pg.create_product(@fc.feed_id, "sku", "product name", @b.name, @fc.feed_category, @fc.feed_subcategory, 
      @fc.feed_product_group, 100.0, :sale_price => 100.0)
    
    matches = @u.matching_products :min_discount => 0.2
    assert_equal 0, matches.length
  end
  
  def test_price_match_existing_sale_worse_than_previous

    # Create a product that I know the user has
    @pg.create_product(@fc.feed_id, "sku", "product name", @b.name, @fc.feed_category, @fc.feed_subcategory, 
      @fc.feed_product_group, 100.0, :sale_price => 90.0)
    
    # Update the product
    @pg.create_product(@fc.feed_id, "sku", "product name", @b.name, @fc.feed_category, @fc.feed_subcategory, 
      @fc.feed_product_group, 100.0, :sale_price => 95.0)
    
    matches = @u.matching_products
    assert_equal 0, matches.length
  end
  
  def test_price_match_for_old_product
  
    # Update the product
    @pg.create_product(@fc.feed_id, "sku", "product name", @b.name, @fc.feed_category, @fc.feed_subcategory, 
      @fc.feed_product_group, 100.0, :sale_price => 90.0, :created_at => @t - 100000)
    
    matches = @u.matching_products
    assert_equal 0, matches.length
  end
  
  def test_multiple_matches
    # Create a product that I know the user has
    @pg.create_product(@fc.feed_id, "sku", "product name", @b.name, @fc.feed_category, 
      @fc.feed_subcategory, @fc.feed_product_group, 100.0, :sale_price => 90.0)
    @pg.create_product(@fc.feed_id, "sku2", "product name2", @b.name, @fc.feed_category, 
      @fc.feed_subcategory, @fc.feed_product_group, 100.0, :sale_price => 90.0)

    matches = @u.matching_products
    assert_equal 2, matches.length
  end
  
  def test_multiple_matches_doesnt_exceed_limit
            
    # Create a product that I know the user has
    @pg.create_product(@fc.feed_id, "sku", "product name", @b.name, @fc.feed_category, @fc.feed_subcategory, 
      @fc.feed_product_group, 100.0, :sale_price => 90.0)
    @pg.create_product(@fc.feed_id, "sku2", "product name2", @b.name, @fc.feed_category, @fc.feed_subcategory, 
      @fc.feed_product_group, 100.0, :sale_price => 90.0)
        
    matches = @u.matching_products(:limit => 1)
    assert_equal 1, matches.length
  end
  
  def test_default_created_at_date_works    
        
    p = @pg.create_product(@fc.feed_id, "weeee", "blar blar blar", @b.name, @fc.feed_category, 
      @fc.feed_subcategory, @fc.feed_product_group, 100.0, :sale_price => 90.0)

    assert_not_nil p
    assert_equal p.brand.id, @b.id

    matches = @u.matching_products
    assert_equal matches[0], p
    assert_equal 1, matches.length
  end
  
  def test_non_matching_product
              
    # This product shouldn't match
    p = @pg.create_product(@fc.feed_id, "sku2", "product name2", "barf brand", "barfers", "woot", "waht", 
      100.0, :sale_price => 90.0, :created_at => @t)
    
    matches = @u.matching_products
    assert_equal 0, matches.length
  end
  
  def test_non_matching_feed_category

    # This product shouldn't match
    p = @pg.create_product(@fc.feed_id, "sku2", "product name2", @b.name, "barfers", "woot", "waht", 
      100.0, :sale_price => 90.0, :created_at => @t)
    
    matches = @u.matching_products
    assert_equal 0, matches.length
  end

  def test_matches_with_department_matching_case
        
    # Create a product that I know the user has
    p = @pg.create_product(@fc.feed_id, "SkuPoo", "Foo Bar - Men's", @b.name, @fc.feed_category, 
      @fc.feed_subcategory, @fc.feed_product_group, 100.0, :sale_price => 90.0, 
      :created_at => @t)
      
    matches = @u.matching_products
    assert_equal 1, matches.length
  end
  
  def test_non_matching_department_case

    # Create a product that I know the user doesn't have
    p = @pg.create_product(@fc.feed_id, "SkuPoo", "Foo Bar - Kids", @b.name, @fc.feed_category, 
      @fc.feed_subcategory, @fc.feed_product_group, 100.0, :sale_price => 90.0, 
      :created_at => @t)
      
    assert_equal departments(:kids), p.department
      
    matches = @u.matching_products
    assert_equal 0, matches.length
    
  end
  
  def test_nil_department_case_matches
    
    # Create 2 products that I know the user has
    p1 = @pg.create_product(@fc.feed_id, "SkuPoo1", "PIGS!!", @b.name, @fc.feed_category, 
      @fc.feed_subcategory, @fc.feed_product_group, 100.0, :sale_price => 90.0, 
      :created_at => @t)    

    p2 = @pg.create_product(@fc.feed_id, "SkuPoo2", "MONKEYS!!", @b.name, @fc.feed_category, 
      @fc.feed_subcategory, @fc.feed_product_group, 100.0, :sale_price => 90.0, 
      :created_at => @t)
      
    # Create a product that I know the user doesn't have
    p3 = @pg.create_product(@fc.feed_id, "SkuPoo3", "Foo Bar - Kids", @b.name, @fc.feed_category, 
      @fc.feed_subcategory, @fc.feed_product_group, 100.0, :sale_price => 90.0, 
      :created_at => @t)
      
    assert_nil p1.department
    assert_nil p2.department
          
    matches = @u.matching_products
    assert_equal 2, matches.length    
    assert_equal [p1, p2], matches
  end
  
  def test_kids_only_has_kids_no_nil
    # Create 2 products that I know the user has
    p1 = @pg.create_product(@fc.feed_id, "SkuPoo1", "PIGS!!", @b.name, @fc.feed_category, 
      @fc.feed_subcategory, @fc.feed_product_group, 100.0, :sale_price => 90.0, 
      :created_at => @t)    

    p2 = @pg.create_product(@fc.feed_id, "SkuPoo2", "Kids pants", @b.name, @fc.feed_category, 
      @fc.feed_subcategory, @fc.feed_product_group, 100.0, :sale_price => 90.0, 
      :created_at => @t)
      
    p3 = @pg.create_product(@fc.feed_id, "SkuPoo3", "mens pants", @b.name, @fc.feed_category, 
      @fc.feed_subcategory, @fc.feed_product_group, 100.0, :sale_price => 90.0, 
      :created_at => @t)    

    p4 = @pg.create_product(@fc.feed_id, "SkuPoo4", "womens pants", @b.name, @fc.feed_category, 
      @fc.feed_subcategory, @fc.feed_product_group, 100.0, :sale_price => 90.0, 
      :created_at => @t)    
      
    # Rob only has kids
    matches = users(:rob).matching_products
    assert_equal 1, matches.length
    assert_equal Department::DEPT_KIDS, matches[0].department.value
  end
  
  def test_user_with_no_departments
    
    # Create 2 products that I know the user has
    p1 = @pg.create_product(@fc.feed_id, "SkuPoo1", "PIGS!!", @b.name, @fc.feed_category, 
      @fc.feed_subcategory, @fc.feed_product_group, 100.0, :sale_price => 90.0, 
      :created_at => @t)    

    p2 = @pg.create_product(@fc.feed_id, "SkuPoo2", "Kids pants", @b.name, @fc.feed_category, 
      @fc.feed_subcategory, @fc.feed_product_group, 100.0, :sale_price => 90.0, 
      :created_at => @t)
      
    p3 = @pg.create_product(@fc.feed_id, "SkuPoo3", "mens pants", @b.name, @fc.feed_category, 
      @fc.feed_subcategory, @fc.feed_product_group, 100.0, :sale_price => 90.0, 
      :created_at => @t)    

    p4 = @pg.create_product(@fc.feed_id, "SkuPoo4", "womens pants", @b.name, @fc.feed_category, 
      @fc.feed_subcategory, @fc.feed_product_group, 100.0, :sale_price => 90.0, 
      :created_at => @t)
    
    matches = users(:vince).matching_products
    assert_equal 1, matches.length
    assert_nil matches[0].department_id
  end
  
  def test_user_mixed_departments
    
    # Create 2 products that I know the user has
    p1 = @pg.create_product(@fc.feed_id, "SkuPoo1", "PIGS!!", @b.name, @fc.feed_category, 
      @fc.feed_subcategory, @fc.feed_product_group, 100.0, :sale_price => 90.0, 
      :created_at => @t)    

    p2 = @pg.create_product(@fc.feed_id, "SkuPoo2", "Kids pants", @b.name, @fc.feed_category, 
      @fc.feed_subcategory, @fc.feed_product_group, 100.0, :sale_price => 90.0, 
      :created_at => @t)
      
    p3 = @pg.create_product(@fc.feed_id, "SkuPoo3", "mens pants", @b.name, @fc.feed_category, 
      @fc.feed_subcategory, @fc.feed_product_group, 100.0, :sale_price => 90.0, 
      :created_at => @t)    

    p4 = @pg.create_product(@fc.feed_id, "SkuPoo4", "womens pants", @b.name, @fc.feed_category, 
      @fc.feed_subcategory, @fc.feed_product_group, 100.0, :sale_price => 90.0, 
      :created_at => @t)
      
    matches = users(:chad).matching_products
    assert_equal 3, matches.length
    # Make sure department kids is not in the list
    matches.each { |p| assert p.department.value != Department::DEPT_KIDS if p.department }
  end
    
  
  def test_make_sure_email_summary_generated

    # Create a product that I know the user has
    p = @pg.create_product(@fc.feed_id, "SkuPoo", "Foo Bar - Men's", @b.name, @fc.feed_category, 
      @fc.feed_subcategory, @fc.feed_product_group, 100.0, :sale_price => 90.0, :created_at => @t)
          
    @pm.generate_emails                
            
    # Assert summary row was created
    upe = UserProductEmail.find_by_user_id(@u.id, :include => [:user])
    assert_not_nil upe
    assert_equal @u, upe.user
  end
  
  def test_brand_match_funky_name
    # Brands with funky names get matched the same as brands that exist with the same name
    # Create a product that I know the user has
    
    funkified = " '''    #{@b.name.upcase} '''  " 
    
    p = @pg.create_product(@fc.feed_id, "SkuPoo", "Foo Bar - Men's", funkified, @fc.feed_category, 
      @fc.feed_subcategory, @fc.feed_product_group, 100.0, :sale_price => 90.0, 
      :created_at => @t)
      
    matches = @u.matching_products
    assert_equal 1, matches.length
  end
  
  def test_no_summary_generated_on_zero_results
    
    UserProductEmail.delete_all
    
    emails_sent = @pm.generate_emails
        
    # Assert email was generated
    assert_equal ActionMailer::Base.deliveries.length, 0
        
    # Assert summary row was not created
    upe = UserProductEmail.find(:all)
    assert_equal 0, upe.length
    assert_equal 0, emails_sent    
  end
  
  def test_dry_run_doesnt_send_emails
    
    # Create a product that I know the user has
    p = @pg.create_product(@fc.feed_id, "SkuPoo", "Foo Bar - Men's", @b.name, @fc.feed_category, 
      @fc.feed_subcategory, @fc.feed_product_group, 100.0, :sale_price => 90.0, :created_at => @t)
          
    pm = AlertGenerator::ProductFeedMatcher.new(:dry_run => true)
    pm.generate_emails
                
    # Assert only one user gets an email
    assert_equal 0, ActionMailer::Base.deliveries.length   
  end
  
  def test_user_product_mails_create_once_per_product
    
    # Clean out the fixtures
    UserProductEmail.delete_all
    
    # Create a product that I know the user has
    p1 = @pg.create_product(@fc.feed_id, "sku", "product name", @b.name, @fc.feed_category, 
      @fc.feed_subcategory, @fc.feed_product_group, 100.0, :sale_price => 90.0)
      
    p2 = @pg.create_product(@fc.feed_id, "sku2", "product name2", @b.name, @fc.feed_category, 
      @fc.feed_subcategory, @fc.feed_product_group, 100.0, :sale_price => 90.0)
    
    @pm.generate_emails
                                      
    # Assert summary row was created
    upe = UserProductEmail.find_by_user_id(@u.id, :include => [:user])
    assert_not_nil upe
    assert_equal @u, upe.user    
  end
    
  def test_day_of_week_prohibits_match
    
    dow = User::get_day_of_week(Time.zone.now)
    
    # User matches today
    users = User::get_eligible_users
    assert_equal users.include?(@u), true
    
    # Remove current users match for today
    EmailDayPreference.delete_all(:day_of_week => dow)
    
    assert_equal User::get_eligible_users.length, 0
  end

  def test_category_array_basic

    p = @pg.create_product(@fc.feed_id, "sku", "product name", @b.name, @fc.feed_category, @fc.feed_subcategory, 
      @fc.feed_product_group, 100.0, :sale_price => 90.0)
    
    matches = @u.matching_products
    cats = @pm.make_category_array(matches)
    
    category = cats[0][0]
    product_rows = cats[0][1]
    products = product_rows[0]

    assert_equal 1, cats.length
    assert_equal 1, products.length    
    assert_equal Category.exists?(category), true
    assert_equal products[0].id, p.id
    assert_equal Product.exists?(products[0]), true
  end
 
end
