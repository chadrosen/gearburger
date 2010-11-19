require 'test_helper'
require 'product_feed_matcher'
require 'product_generator'

class ProductFeedMatcherTest < ActiveSupport::TestCase

  fixtures :users

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
    
    # Delete everything in product_emails dir
    path = File.join(OPTIONS[:product_email_location], "*_#{Time.zone.today}.email")
    file_names = Dir.glob(path)
    file_names.each do |f|
      p = File.join("#{OPTIONS[:product_email_location]}", f)
      File.delete(f)
    end
    
    Product.delete_all
  end

  def test_price_matching_no_matches
    matches = @pm.get_matching_products(users(:chad))    
    assert_equal matches.length, 0
  end
  
  def test_price_match_new_product_with_sale        
    # Create a product that I know the user has
    @pg.create_product(@fc.feed_id, "sku", "product name", @b.name, @fc.feed_category, @fc.feed_subcategory, 
      @fc.feed_product_group, 100.0, :sale_price => 90.0)
    
    matches = @pm.get_matching_products(@u)
    assert_equal matches.length, 1
  end
  
  def test_price_match_new_product_with_no_sale

    @pg.create_product(@fc.feed_id, "sku", "product name", @b.name, @fc.feed_category, @fc.feed_subcategory, 
      @fc.feed_product_group, 100.0, :sale_price => 100.0)
    
    matches = @pm.get_matching_products(@u, :min_discount => 0.2)
    assert_equal matches.length, 0
  end
  
  def test_price_match_existing_sale_worse_than_previous

    # Create a product that I know the user has
    @pg.create_product(@fc.feed_id, "sku", "product name", @b.name, @fc.feed_category, @fc.feed_subcategory, 
      @fc.feed_product_group, 100.0, :sale_price => 90.0)
    
    # Update the product
    @pg.create_product(@fc.feed_id, "sku", "product name", @b.name, @fc.feed_category, @fc.feed_subcategory, 
      @fc.feed_product_group, 100.0, :sale_price => 95.0)
    
    matches = @pm.get_matching_products(@u)
    assert_equal matches.length, 0
  end
  
  def test_price_match_for_old_product
  
    # Update the product
    @pg.create_product(@fc.feed_id, "sku", "product name", @b.name, @fc.feed_category, @fc.feed_subcategory, 
      @fc.feed_product_group, 100.0, :sale_price => 90.0, :created_at => @t - 100000)
    
    matches = @pm.get_matching_products(@u)
    assert_equal matches.length, 0
  end
  
  def test_multiple_matches
    # Create a product that I know the user has
    @pg.create_product(@fc.feed_id, "sku", "product name", @b.name, @fc.feed_category, 
      @fc.feed_subcategory, @fc.feed_product_group, 100.0, :sale_price => 90.0)
    @pg.create_product(@fc.feed_id, "sku2", "product name2", @b.name, @fc.feed_category, 
      @fc.feed_subcategory, @fc.feed_product_group, 100.0, :sale_price => 90.0)

    matches = @pm.get_matching_products(@u)
    assert_equal matches.length, 2
  end
  
  def test_multiple_matches_doesnt_exceed_limit
            
    # Create a product that I know the user has
    @pg.create_product(@fc.feed_id, "sku", "product name", @b.name, @fc.feed_category, @fc.feed_subcategory, 
      @fc.feed_product_group, 100.0, :sale_price => 90.0)
    @pg.create_product(@fc.feed_id, "sku2", "product name2", @b.name, @fc.feed_category, @fc.feed_subcategory, 
      @fc.feed_product_group, 100.0, :sale_price => 90.0)
        
    matches = @pm.get_matching_products(@u, :limit => 1)
    assert_equal matches.length, 1
  end
  
  def test_default_created_at_date_works    
        
    p = @pg.create_product(@fc.feed_id, "weeee", "blar blar blar", @b.name, @fc.feed_category, 
      @fc.feed_subcategory, @fc.feed_product_group, 100.0, :sale_price => 90.0)

    assert_not_nil p
    assert_equal p.brand.id, @b.id

    matches = @pm.get_matching_products(@u)
    assert_equal matches[0], p
    assert_equal matches.length, 1
  end
  
  def test_non_matching_product
              
    # This product shouldn't match
    p = @pg.create_product(@fc.feed_id, "sku2", "product name2", "barf brand", "barfers", "woot", "waht", 
      100.0, :sale_price => 90.0, :created_at => @t)
    
    matches = @pm.get_matching_products(@u)
    assert_equal matches.length, 0
  end
  
  def test_non_matching_feed_category

    # This product shouldn't match
    p = @pg.create_product(@fc.feed_id, "sku2", "product name2", @b.name, "barfers", "woot", "waht", 
      100.0, :sale_price => 90.0, :created_at => @t)
    
    matches = @pm.get_matching_products(@u)
    assert_equal matches.length, 0
  end

  def test_matches_with_department_matching_case
        
    # Create a product that I know the user has
    p = @pg.create_product(@fc.feed_id, "SkuPoo", "Foo Bar - Men's", @b.name, @fc.feed_category, 
      @fc.feed_subcategory, @fc.feed_product_group, 100.0, :sale_price => 90.0, 
      :created_at => @t)
      
    matches = @pm.get_matching_products(@u)
    assert_equal matches.length, 1    
  end
  
  def test_make_sure_email_summary_generated

    # Create a product that I know the user has
    p = @pg.create_product(@fc.feed_id, "SkuPoo", "Foo Bar - Men's", @b.name, @fc.feed_category, 
      @fc.feed_subcategory, @fc.feed_product_group, 100.0, :sale_price => 90.0, :created_at => @t)
          
    @pm.generate_emails
                
    # Assert only one user gets an email
    active_users = User.find_all_by_state(:active)
    assert_equal ActionMailer::Base.deliveries.length, 2
        
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
      
    matches = @pm.get_matching_products(@u)
    assert_equal matches.length, 1
  end
  
  def test_no_summary_generated_on_zero_results
    
    UserProductEmail.delete_all
    
    emails_sent = @pm.generate_emails
        
    # Assert email was generated
    assert_equal ActionMailer::Base.deliveries.length, 0
        
    # Assert summary row was not created
    upe = UserProductEmail.find(:all)
    assert_equal upe.length, 0
    assert_equal emails_sent, 0    
  end
  
  def test_dry_run_doesnt_send_emails
    
    # Create a product that I know the user has
    p = @pg.create_product(@fc.feed_id, "SkuPoo", "Foo Bar - Men's", @b.name, @fc.feed_category, 
      @fc.feed_subcategory, @fc.feed_product_group, 100.0, :sale_price => 90.0, :created_at => @t)
          
    pm = AlertGenerator::ProductFeedMatcher.new(:dry_run => true)
    pm.generate_emails
                
    # Assert only one user gets an email
    assert_equal ActionMailer::Base.deliveries.length, 0    
  end
  
  def test_user_product_mails_create_once_per_product
    
    # Clean out the fixtures
    ProductsUser.delete_all
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
    
    pus = upe.products_users(:order => "product_id ASC")
    assert_not_nil pus
    assert_equal pus.length, 2
    assert_equal pus[0].product, p1
    assert_equal pus[1].product, p2
    
    # Make sure counter cache works
    assert_equal upe.products_users_count, pus.length  
  end
  
  def test_creating_mail_no_matches
    
     @pm.create_emails
     
     # Nothing created
     path = File.join(OPTIONS[:product_email_location], "*_#{Time.zone.today}.email")
     file_names = Dir.glob(path)
     assert_equal file_names.length, 0
    
  end
  
  def test_creating_mail_with_matches
    
    # Create a product that I know the user has
    @pg.create_product(@fc.feed_id, "sku", "product name", @b.name, @fc.feed_category, @fc.feed_subcategory, 
      @fc.feed_product_group, 100.0, :sale_price => 90.0)
    
    @pm.create_emails
    
    path = File.join(OPTIONS[:product_email_location], "*_#{Time.zone.today}.email")
    file_names = Dir.glob(path)
    assert_equal file_names.length, 5 # I guess 5 users match this product
  end
  
  def test_delivering_created_mail
    
    # Create a product that I know the user has
    p = @pg.create_product(@fc.feed_id, "sku", "product name", @b.name, @fc.feed_category, @fc.feed_subcategory, 
      @fc.feed_product_group, 100.0, :sale_price => 90.0)
   
    @pm.create_emails
    
    path = File.join(OPTIONS[:product_email_location], "*_#{Time.zone.today}.email")
    file_names = Dir.glob(path)
    
    @pm.deliver_email(file_names[0])
    
    assert_equal ActionMailer::Base.deliveries.length, 1    
  end
  
  def test_delivering_batched_emails

    # Create a product that I know the user has
    @pg.create_product(@fc.feed_id, "sku", "product name", @b.name, @fc.feed_category, @fc.feed_subcategory, 
      @fc.feed_product_group, 100.0, :sale_price => 90.0)

    @pm.create_emails
    @pm.deliver_in_batches
    
    assert_equal ActionMailer::Base.deliveries.length, 5  
  end
  
  def test_deliver_mail_multiple_times_same_day
    
    # Create a product that I know the user has
    @pg.create_product(@fc.feed_id, "sku", "product name", @b.name, @fc.feed_category, @fc.feed_subcategory, 
      @fc.feed_product_group, 100.0, :sale_price => 90.0)

    @pm.create_emails
    @pm.create_emails
    @pm.create_emails
    
    @pm.deliver_in_batches
    
    assert_equal ActionMailer::Base.deliveries.length, 5    
    
  end
  
  def test_day_of_week_prohibits_match
    
    dow = @pm.get_day_of_week(Time.zone.now)
    
    # User matches today
    users = @pm.get_eligible_users()
    assert_equal users.include?(@u), true
    
    # Remove current users match for today
    EmailDayPreference.delete_all(:day_of_week => dow)
    
    assert_equal @pm.get_eligible_users.length, 0
  end

  def test_category_array_basic

    p = @pg.create_product(@fc.feed_id, "sku", "product name", @b.name, @fc.feed_category, @fc.feed_subcategory, 
      @fc.feed_product_group, 100.0, :sale_price => 90.0)
    
    matches = @pm.get_matching_products(@u)
    cats = @pm.make_category_array(matches)
    
    category = cats[0][0]
    product_rows = cats[0][1]
    products = product_rows[0]

    assert_equal cats.length, 1
    assert_equal products.length, 1    
    assert_equal Category.exists?(category), true
    assert_equal products[0].id, p.id
    assert_equal Product.exists?(products[0]), true
  end
 
end
