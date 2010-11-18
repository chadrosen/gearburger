require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  fixtures :users
  
  def teardown
    ActionMailer::Base.deliveries = []
  end

  def test_should_create_user
    assert_difference 'User.count' do
      user = create_user
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_initialize_activation_code_upon_creation
    user = create_user
    user.reload
    assert_not_nil user.activation_code
  end

  def test_should_create_and_start_in_pending_state
    user = create_user
    user.reload
    assert user.pending?
  end

  def test_new_record_will_generate_password
    #TODO
  end

  def test_should_require_email
    assert_no_difference 'User.count' do
      u = create_user(:email => nil)
      assert !u.errors[:email].empty?
    end
  end

  def test_should_not_reset_password
    users(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_not_equal users(:quentin), User.authenticate('quentin@example.com', 'new password')
  end

  def test_should_not_rehash_password
    users(:quentin).update_attributes(:email => 'quentin2@example.com')
    assert_equal users(:quentin), User.authenticate('quentin2@example.com', 'monkey')
  end

  def test_should_authenticate_user
    assert_equal users(:quentin), User.authenticate('quentin@example.com', 'monkey')
  end

  def test_should_register_pending_user
    user = create_user(:password => nil, :password_confirmation => nil)
    assert user.pending?
    user.update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert user.pending?
  end

  def test_should_deactivate_user
    users(:quentin).deactivate!
    assert users(:quentin).inactive?
  end

  def test_deactivated_user_should_authenticate
    users(:quentin).deactivate!
    assert_equal users(:quentin), User.authenticate('quentin@example.com', 'monkey')
  end

  def test_should_unsuspend_user_to_active_state
    users(:quentin).deactivate!
    assert users(:quentin).inactive?
    users(:quentin).activate!
    assert users(:quentin).active?
  end
  
  def test_password_generation
    p = User.generate_password(5)
    assert !p.empty?
  end
  
  def test_empty_password_generation
    p = User.generate_password(0)
    assert p.empty?
  end
  
  def test_password_reset
    u = users(:quentin)
    old_password = u.crypted_password
    u.reset_password!
    assert u.crypted_password != old_password
    assert_nil User.authenticate(u.email, old_password)
  end
  
  def test_valid_registration
    user = User.register("chadrosen@hotmail.com")
    assert_nil user.referrer 
    
    # assert default price stuff
    assert_equal user.min_discount, 0.2
    assert_equal user.min_price, 0.0
    assert_equal user.max_price, 5000.0 
    assert user.valid?      
  end
  
  def test_invalid_campaign_creation
    user = User.register("chadrosen@hotmail.com", :campaign_id => "asdfasdf")
    assert user.valid?
    
    assert user.campaign.nil?
  end
  
  def test_valid_campaign_creation
    
    c = Campaign.create!(:name => "chadchad", :public_id => "foofoo")
    
    user = User.register("chadrosen@hotmail.com", :campaign_id => "foofoo")
    assert user.valid?
    
    assert_equal user.campaign, c
  end
  
  def test_break_parser
    
    today = Time.zone.now
        
    assert_equal User.break_parser(today, 1, "week"), today + 1.weeks
    assert_equal User.break_parser(today, 1, "month"), today + 1.month    
  end
  
  def test_user_take_a_break_one_week

    today = Time.zone.now
    u = users(:chad)
    assert_equal u.state, "active"
    u.take_a_break!(today, User::BreakOneWeek)
    
    assert_equal u.state, "break"
    assert_equal u.break_started_at, today
    assert_equal u.break_ends_at, today + 1.weeks    
  end
  
  def test_user_take_a_break_nine_months
    today = Time.zone.now
    u = users(:chad)
    assert_equal u.state, "active"
    u.take_a_break!(today, User::BreakNineMonths)
    
    assert_equal u.state, "break"
    assert_equal u.break_started_at.getutc, today
    assert_equal u.break_ends_at.getutc, User::break_parser(today, 9, "months")
  end
  
  def test_break_clearer_same_day
    
    today = Time.zone.now
    u = users(:chad)
    assert_equal u.state, "active"
    u.user_breather!(today - 2.hours, today - 1.hours)
    
    assert_equal u.state, "break"
    
    User.clear_break_users(today)
    
    u = User.find_by_email(u.email)
    assert_equal u.state, "active"
  end
  
  def test_break_clearer_months_ago
    
    today = Time.zone.now
    u = users(:chad)
    assert_equal u.state, "active"
    u.user_breather!(today - 3.months, today - 3.months)
    
    assert_equal u.state, "break"
    
    User.clear_break_users(today)
    
    u = User.find_by_email(u.email)
    assert_equal u.state, "active"
    
  end
  
  def test_break_clearer_future_date
    today = Time.zone.now
    u = users(:chad)
    assert_equal u.state, "active"
    u.user_breather!(today, today + 3.months)
    
    assert_equal u.state, "break"
    
    User.clear_break_users(today)
    
    u = User.find_by_email(u.email)
    assert_equal u.state, "break"
  end

  def test_break_clearer_multi_user
    
    today = Time.zone.now
    u1 = users(:chad)
    u2 = users(:vince)
    
    assert_equal u1.state, "active"
    u1.user_breather!(today - 2.hours, today - 1.hours)
    u2.user_breather!(today - 3.years, today - 1.years)
    
    User.clear_break_users(today)
    
    assert_equal User.find_all_by_state("break").length, 0
  end

  def test_min_price_less_than_max
    
    u = users(:chad)
    u.min_price = 0.0
    u.max_price = 100.0
    
    assert u.valid?
    assert_equal 0, u.errors.length
  end
  
  def test_min_price_greater_than_max
    u = users(:chad)
    u.min_price = 100.0
    u.max_price = 0.0
    
    assert !u.valid?
    assert_equal 1, u.errors.length
  end
  
  def test_invalid_min_prices
    u = users(:chad)
    u.min_price = -1.0    
    assert !u.valid?
    assert_equal 1, u.errors.length
    
    u.min_price = 100000.00
    assert !u.valid?
    assert_equal 2, u.errors[:min_price].length
  end
  
  def test_invalid_max_prices
    u = users(:chad)
    u.min_price = 0.0
    u.max_price = -1.0    
    assert !u.valid?
    
     # 2 errors because min price is also invalid
    assert_equal 2, u.errors.length
    
    u.max_price = 100000.00
    assert !u.valid?

    # Only one error here on max price
    assert_equal 1, u.errors.length
  end  
  
protected
  def create_user(options = {})
    record = User.new({:email => 'quire@example.com', :min_price => 0.0, 
      :max_price => 5000.0, :min_discount => 0.2 }.merge(options))
    record.save
    record
  end
end
