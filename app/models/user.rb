require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  
  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message
  
  # Price validations
  validates_numericality_of :min_discount, :greater_than_or_equal_to => 0.0
  validates_numericality_of :min_discount, :less_than_or_equal_to => 1.0
  validates_numericality_of :min_price, :greater_than_or_equal_to => 0.0
  validates_numericality_of :min_price, :less_than_or_equal_to => 10000.00
  validates_numericality_of :max_price, :greater_than_or_equal_to => 0.0
  validates_numericality_of :max_price, :less_than_or_equal_to => 10000.00
  
  # Max products per email must be between 10 and 99
  validates_numericality_of :max_products_per_email, :greater_than_or_equal_to => 10
  validates_numericality_of :max_products_per_email, :less_than_or_equal_to => 100
  
  validates_inclusion_of :state, :in => %w( pending active inactive break )
  
  # TODO: Chad. This type of validation is deprecated in rails 3. I attempted to use the new validators
  # but they weren't accepting floats and got fucked up on BigDecimal. Rails bug?
  
  class MinLessMaxValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if record.min_price >= record.max_price
        record.errors[attribute] << "Min price must be less than max price"
      end
    end
  end
  
  validates :min_price, :min_less_max => true
          
  # A user can have many brands
  has_many :brands_users
  has_many :brands, :through => :brands_users

  # A user can have many categories
  has_many :categories_users
  has_many :categories, :through => :categories_users
  
  # A user can choose to monitor different sex params
  has_many :departments_users
  has_many :departments, :through => :departments_users
    
  has_many :user_product_emails # These are product emails sent to the user
  has_many :clicks
  has_many :sales
  has_many :user_invites # These are all the people the user invited
  has_many :registered_invites, :primary_key => "id", :foreign_key => "referral_id", :class_name => "User"
  has_many :email_day_preferences
  
  # This is the user that referred the existing user
  belongs_to :referrer, :class_name => "User", :foreign_key => "referral_id" 
  
  # A user has been emailed many times about products
  has_many :products_user
  
  # So, we can keep track of which marketing campaign a user comes from
  belongs_to :campaign
  
  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :email, :time_zone, :user_agent, :ip_address, :fb_user_id, :min_discount, :referral_url
  attr_accessible :identity_hash, :first_name, :last_name, :min_price, :max_price, :max_products_per_email
  
  before_validation(:on => :create) {  
    # When creating a new record run (and right before validation) generate a 
    # temporary password and activation code
    self.password = self.password_confirmation = User.generate_password(8)
    self.activation_code = User.make_token
  }
  
  # Options for min discount
  DiscountTen = "10% off"
  DiscountTwenty = "20% off"
  DiscountTwentyFive = "25% off"
  DiscountThirty = "30% off"
  DiscountFourty = "40% off"
  DiscountFifty = "50% off"
  DiscountSixty = "60% off"
  DiscountSeventy = "70% off"
  
  DiscountOptions = [ DiscountTen, DiscountTwenty, DiscountTwentyFive, DiscountThirty, 
    DiscountFourty, DiscountFifty, DiscountSixty, DiscountSeventy ]
    
  DiscountValues = {
    DiscountTen => 0.1,
    DiscountTwenty => 0.2,
    DiscountTwentyFive => 0.25,
    DiscountThirty => 0.30,
    DiscountFourty => 0.40,
    DiscountFifty => 0.50,
    DiscountSixty => 0.60,
    DiscountSeventy => 0.70
  }
  
  # Options for take a break
  BreakOneWeek = "1 week"
  BreakTwoWeeks = "2 week"
  BreakThreeWeeks = "3 week"
  BreakOneMonth = "1 month"
  BreakThreeMonths = "3 month"
  BreakSixMonths = "6 month"
  BreakNineMonths = "9 month"

  BreakOptions = [
    BreakOneWeek, BreakTwoWeeks, BreakThreeWeeks, BreakOneMonth, BreakThreeMonths, 
    BreakSixMonths, BreakNineMonths
  ]
    
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(email, password)
    return nil if email.blank? || password.blank?
    u = User.find_by_email(email.downcase)
    u && u.authenticated?(password) ? u : nil
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  def self.generate_password(length)
    # Generate a random password of x length
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    pass = ""
    1.upto(length) do |i| 
      pass << chars[rand(chars.size-1)]
    end
    return pass
  end

  def reset_password!
    self.password = self.password_confirmation = User.generate_password(8)
    self.save!
    return self.password
  end
    
  def activate!
    self.state = "active"
    self.activated_at = Time.now.utc
    self.deleted_at = self.activation_code = nil
    self.break_started_at = nil
    self.break_ends_at = nil
    self.save!
  end
  
  def deactivate!
    self.state = "inactive"
    self.deleted_at = Time.now.utc
    self.break_started_at = nil
    self.break_ends_at = nil
    self.save!
  end
  
  def self.break_parser(datetime, break_value, time_string)
    # Takes a break value (integer) and a time string (week, month)
    # And converts them into time from now. The user is then "given a breather"
    (time_string == "week") ? datetime + break_value.weeks : datetime + break_value.months
  end
  
  def take_a_break!(time_start, break_constant)
    # User wants to take a break
    time_value, time_string = break_constant.split(" ")
    time_value = time_value.to_i    
    
    end_date = User.break_parser(time_start, time_value, time_string)
    user_breather!(time_start, end_date)
  end
  
  def user_breather!(break_started_at, break_ends_at)
    # Put the user on a break from start until end. Use take_a_break! if calling this
    # method from the app
    self.state = "break"
    self.break_started_at = break_started_at.getutc
    self.break_ends_at = break_ends_at.getutc
    self.save!
  end
  
  def clear_breather!
    self.state = "active"
    self.break_started_at = nil
    self.break_ends_at = nil
    self.save!
  end
  
  def self.clear_break_users(end_date)
    # Remove the break from any user that is on a break and the end_date is less than today 
    conditions = ["state = 'break' AND break_ends_at <= ?", end_date.getutc.to_s(:date_end)]
    users = User.where(conditions).all
    users.each { |u| u.clear_breather! }
  end
  
  def active?
    self.state == "active"
  end
  
  def pending?
    self.state == "pending"
  end
  
  def inactive?
    self.state == "inactive"
  end
  
  def break?
    self.state == "break"
  end
  
  def following_product(product_id)
    # TODO: make this more efficient
    products = self.products.collect { |p| p.id }
    return products.include?(product_id) ? true : false
  end
    
  def has_email_pref(edp)
    # TODO: This may not be the best way to do this...
    r = self.email_day_preferences.select { |d| d.day_of_week == edp }
    return r.length > 0
  end
  
  def self.register(email, options = {})
    
    time_zome = options[:time_zone] || Time.zone.name
    min_discount = options[:min_discount] || 0.2
    min_price = options[:min_price] || 0.0
    max_price = options[:max_price] || 5000.0
    categories = options[:categories] || []
    departments = options[:departments] || []
    
    user = nil
    
    User.transaction do 
            
      # Set default price settings
      user = User.new( 
        :email => email,
        :min_discount => min_discount, 
        :min_price => min_price, 
        :max_price => max_price,
        :first_name => options[:first_name], 
        :last_name => options[:last_name],
        :referral_url => options[:referral_url],
        :ip_address => options[:ip_address], 
        :user_agent => options[:user_agent], 
        :fb_user_id => options[:fb_user_id]
      )

      # Add categories and departments
      user.categories = Category.find(categories)
      user.departments = Department.find(departments)
      
      # Check to see if there is a referral. There can be many. Only use the first row..
      referral = UserInvite.find_by_email_address(user.email, :order => "created_at ASC")
      user.referral_id = referral.user_id if referral
      
      # Add the campaign if it's valid
      user.campaign = Campaign.find_by_public_id(options[:campaign_id])
            
      # Add every day to the email preferences
      EmailDayPreference::DaysOfWeek.each do |d| 
        user.email_day_preferences << EmailDayPreference.new(:day_of_week => d)
      end
            
      # Save the whole package
      user.save!      
    end
    
    return user
  end
  
  def matching_products(options = {})
    # Called on the individual user object
    return User::get_matching_products(self, options)
  end
    
  def self.get_matching_products(user, options = {})
    # Get a list of products matching a user's selections that
    # have a price change recently that is favorable

    # Optimization: no need to even run the query unless the user has categories
    return [] if user.categories.empty?
    
    # Run for last 24 hours by default & make sure UTC
    sd = options[:start_date] ? Time.parse(options[:start_date]) : Time.zone.now - 1.days
    sd = sd.utc unless sd.utc?
    ed = options[:end_date] ? Time.parse(options[:end_date]) : Time.zone.now
    ed = ed.utc unless ed.utc?
                        
    # Default price stuff to user values but can be overridden
    min_discount = options[:min_discount] || user.min_discount
    min_price = options[:min_price] || user.min_price
    max_price = options[:max_price] || user.max_price
    limit = options[:limit] || user.max_products_per_email

    # Get feed category ids for the user in one query...
    fcs = FeedCategory.where(:category_id => user.categories).select("DISTINCT(id)").all
    
    # Get the user's brand_ids in one query...
    brands = user.brands.map { |b| b.id }
      
    # Non department case query section
    q = Product.where(:feed_category_id => fcs)
    
    # Only add brands if the user has specified them. Otherwise, assume all brands
    q = q.where(:brand_id => brands) unless brands.empty?
    
    # Product must have a price change within a certain span of time
    q = q.where(["price_changed_at BETWEEN ? AND ?", sd, ed])
    
    # The product must be validated by our auto-nightly-validator
    q = q.where(:valid_sale_price => true)
    
    # Sale price restrictions
    q = q.where(["sale_price BETWEEN ? AND ?", min_price, max_price])
    
    # The item's discount must be greater or equal to the min discount
    q = q.where(["(retail_price - sale_price) / retail_price >= ?", min_discount])
    
    # The product must either be new or on sale
    q = q.where("previous_sale_price = 0.0 OR sale_price < previous_sale_price")

    # Add some extra data objects to the result
    q.includes([:category, :brand])
    
    # Get the results
    result = q.all
    
    # Do the query again but this time filter adding departments
    result2 = q.where(:department_id => user.departments).all
    
    # Return union of both arrays
    r = result | result2
    
    # ?
    # TODO: Figure out how to order the final merged result
    # :order => "(retail_price - sale_price) / retail_price DESC")
    #result.sort_by { |p| (p.retail_price - p.sale_price) / retail_price }
    
    # If there's a limit, limit the result set
    return limit ? r[0...limit] : r
  end
  
  def self.get_eligible_users(options = {})
    # Get all of the active users that want the email..
    
    # Get the day of week so we can make sure the user wants the email
    d = options[:date] ? Time.parse(options[:date]) : Time.zone.today
    dow = self.get_day_of_week(d)
    
    User.find(:all, :joins => [:email_day_preferences], 
      :conditions => {"users.state" => "active", "email_day_preferences.day_of_week" => dow})        
  end
  
  def self.get_day_of_week(date)
    # Returns the day of the week from a day string
    return EmailDayPreference::DaysOfWeek[date.strftime("%w").to_i]
  end
  
end
