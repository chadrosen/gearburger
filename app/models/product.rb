class Product < ActiveRecord::Base
      
  # A product has many sale prices
  has_many :product_prices
  
  # A single product will probably be in many different emails to users
  has_many :products_user
  
  # A product get it's category through the feed category
  has_one :category, :through => :feed_category
    
  # Set of sub items for a product
  belongs_to :feed_category
  belongs_to :department
  belongs_to :brand
  belongs_to :feed
  
  has_many :clicks
      
  # validation
  validates_presence_of :product_name, :sku
  validates_numericality_of :retail_price

  # These are so confusing... http://www.ruby-forum.com/topic/95220
  # Attributes to dynamically store price history metrics
  attr_accessor :avg_price, :min_price, :max_price
  attr_accessible :valid_sale_price, :valid_small_image, :sku, :feed_id

  def self.get_price_percentage(retail_price, sale_price)
    # Get the percentage off of a sale price compared to retail price
    
    # NOTE: This was defined in helpers but i need it in action mailer emails which dont have access

     # Get the result as a percentage of the original
    begin
      result = ((retail_price.to_f - sale_price.to_f) / retail_price.to_f) * 100
      # always round the result up to the nearest float
      return result.ceil.to_f
    rescue
      return 0.0
    end    
  end
  
  def get_price_percentage
    # Same method as above but uses methods on the object
    return Product.get_price_percentage(self.retail_price, self.sale_price)
  end

  def self.get_changed_products(options = {})
    offset = options[:offset]
    limit = options[:limit]
    threshold = options[:threshold] || 0
 
    # Run for last 24 hours by default
    sd = options[:start_date] ? Time.parse(options[:start_date]) : Time.zone.now - 1.days
    sd = sd.utc unless sd.utc?
    ed = options[:end_date] ? Time.parse(options[:end_date]) : Time.zone.now
    ed = ed.utc unless ed.utc?

    # Get all of the products that have valid GB categories, price changed today,
    # retail < sale price, they are either a new product (0.0) or the price is less than the last
    # time we checked
    sql = "feed_categories.category_id IS NOT NULL AND price_changed_at BETWEEN ? AND ? 
      AND sale_price < (retail_price * (1 - ?)) AND (previous_sale_price = 0.0 OR sale_price < previous_sale_price)"
                 
    q = Product.where([sql, sd.strftime("%Y-%m-%d %H:%M:%S"), ed.strftime("%Y-%m-%d %H:%M:%S"), threshold])
    q = q.includes([:brand, :feed_category]).order("(1 - sale_price/retail_price) DESC")
    q.offset(offset).limit(limit).all
  end
  
  def self.get_products_by_params(options = {})
    
    start_date = options[:start_date] || (Time.zone.now - 30.days).to_s(:date_start)
    end_date = options[:end_date] || Time.zone.now.to_s(:date_end)
    min_discount = options[:min_discount] ? options[:min_discount].to_d : 0.2
    min_price = options[:min_price] ? options[:min_price].to_d : 0.0
    max_price = options[:max_price] ? options[:max_price].to_d : 5000.0
    
    page = options[:page] ? options[:page].to_i : 1
    per_page = options[:per_page] ? options[:per_page].to_i : 100
    
    start = page == 1 ? 0 : (page - 1) * per_page
    
    sql = "price_changed_at BETWEEN ? AND ? AND sale_price BETWEEN ? AND ?" 
    sql += " AND (retail_price - sale_price) / retail_price >= ?"
    
    # By default only include valid sale data if specified    
    if !options[:valid_sale].nil? 
      sql += " AND valid_sale_price = #{options[:valid_sale]}"
    end    
    
    conditions = [sql, start_date, end_date, min_price, max_price, min_discount]
              
    q = Product.where(conditions).order("(retail_price - sale_price) / sale_price DESC")
    q.includes([:category, :department]).limit(per_page).offset(start).all
  end
  
  def discount
    begin
      return (self.retail_price - self.sale_price) / self.retail_price
    rescue
      return 0.0
    end
  end
  
  def get_small_image_url
    # Returns a placeholder geartrude image if the product image is not valid
    gbl = '/images/img_not_found.png'
    return gbl unless self.valid_small_image
    return gbl if self.small_image_url.nil? 
    return self.small_image_url 
  end
  
  def as_json(options={})  
    {
      "product_name" => self.product_name,
		  "category_id" => self.category ? self.category.id : 0,
		  "sale_price" => self.sale_price.to_f,
		  "retail_price" => self.retail_price.to_f,
		  "buy_url" => self.buy_url,
		  "small_image_url" => self.get_small_image_url(),
		  "price_changed_at" =>  self.price_changed_at.to_i,
		  "discount" => ("%0.2f" % self.discount).to_f, # Ghetto?
		  "department_id" => self.department ? self.department.id : 0
	  }
  end

  
  def populate_price_history

    prices = self.product_prices(:order => "created_at asc")
    unless prices.nil?

      # Initialization
      first = prices.shift
      min_price = first.price
      max_price = first.price
      avg_price = 0

      previous_start = first.created_at
      previous_price = first.price
      total_length = 0

      prices.each do |price|
        start = price.created_at
        price = price.price

        if price > max_price
          max_price = price
        end

        if price < min_price
          min_price = price
        end

        length = start - previous_start
        avg_price = ((total_length * avg_price) + (length * previous_price)) / (total_length + length) 

        total_length += length
        previous_start = start
        previous_price = price
      end

      length = Time.zone.now - previous_start
      avg_price = ((total_length * avg_price) + (length * previous_price)) / (total_length + length)       

      self.min_price = min_price
      self.max_price = max_price
      self.avg_price = avg_price
    end

  end
  
  def to_s
    "Product: #{self.id} - #{self.product_name}"
  end


end
