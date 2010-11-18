require 'open-uri'
require 'zlib'
require 'csv'
require 'bigdecimal'
require 'bigdecimal/util'
require 'stats'

module AlertGenerator

  class FeedParser
    
    def initialize(options = {})
    end
    
    def download_feed(download_location, options = {})
    end
    
    def process_product_feed(feed_file)
    end
    
  end

  class AvantlinkFeedParser < FeedParser
    
    # Columns used in mapping. Note the lack of caps and spaces. This was done on purpose
    # b/c we pull out spaces and caps when matching from the feed
    Sku = "sku"
    BrandName = "brandname"
    ProductName = "productname"
    Category = "category"
    SubCategory = "subcategory"
    ProductGroup = "productgroup"
    ThumbUrl = "thumburl"
    ImageUrl = "imageurl"
    BuyLink = "buylink"
    RetailPrice = "retailprice"
    SalePrice = "saleprice"
    ManufacturerId = "manufacturerid"

    Columns = [Sku, BrandName, ProductName, Category, SubCategory, ProductGroup, ThumbUrl, ImageUrl,
      BuyLink, RetailPrice, SalePrice, ManufacturerId]
      
    RequiredColumns = [Sku, BrandName, ProductName, Category, RetailPrice]
    
    attr_accessor :feed, :limit, :column_mapping, :stats
    
    def initialize(feed, options = {})
      
      @log = Log4r::Logger['product_generator']
      @log.info("Start product generator")
      
      # Turn off stdout and sterr. Makes it helllla fast
      Log4r::Outputter['stderr'].level = Log4r::OFF  
      Log4r::Outputter['standardlog'].level = Log4r::OFF
      
      # Limit the amount of products to process. For debugging
      @limit = options[:limit]      
      
      @column_mapping = {}
      @feed = feed
      @product_generator = ProductGenerator.new(options)
      @stats = nil
    end
        
    def download_feed(download_location, options = {})
            
      # Figure out the date to start from... Default is 1 day ago from now
      from = options[:start_date] || (Time.zone.now - 1.days).strftime("%Y-%m-%d %H:%I:%M")
      from = CGI.escape(from) # Make sure it's escaped
      
      # Create the new file name from the current time
      file_name = "#{@feed.id}-#{Time.now.to_i}.gz"
      feed_file = File.join(download_location, file_name)
  
      @log.debug("Download feed #{file_name} to #{feed_file}")

      if options[:all]
        url = @feed.url
      else
        url = "#{@feed.url}&incr=only-modified&from=#{from}"
      end

      puts "Process: #{@feed.name.downcase} #{url}"
      @log.debug("Avantlink file from #{url}")

      File.open(feed_file, 'w') do |gf|
        f = open(url)
        f.readlines.each { |l| gf.write(l) }
      end

      @log.debug("feed #{@feed.id} downloaded succesfully")
      
      return feed_file
    end
    
    def map_header(header_line)
      # Keep track of the mappings so we can auto process feeds in different order
            
      @column_mapping = {}
      
      # Search for the column location in the header and fill out the result in the mapping hash
      header_line.each_with_index do |col, index|
        header_value = col.delete(" ").downcase
        @column_mapping[header_value] = index
      end
                  
      # Validate the header
      RequiredColumns.each { |c| throw NameError.new("Missing required column: #{c}") unless @column_mapping[c] }      
    end

    def process_product_feed(feed_file)
                                     
      @log.debug("Start file processing")
      start_time = Time.now
      
      count = 0
      errors = 0
      
      File.open(feed_file) do |f|
      
        gz = Zlib::GzipReader.new(f)
        
        # Map the columns from the first line
        map_header(CSV.parse_line(gz.readline))
                                                      
        continue = true
        
        while (line = gz.gets) && continue 
                    
          begin
            create_product_from_csv_line(line)
          rescue Exception => e
            @log.error(e)
            errors += 1
          end

          # Keep track of count so we can limit execution
          count += 1
          continue = false if @limit && count >= @limit            
        end                
      end
      
      stats = @product_generator.stats
      
      end_time = Time.now
      total_time = end_time - start_time
      avg = total_time / (stats[:product_updates] + stats[:new_products] + errors)
      min, sec = convert_seconds_to_time(total_time.seconds)

      # Log some stuff and add a record to the db
      @log.info("--- File Processing complete ---")
      @log.info("Execution time: #{min}m #{sec}s AVG: #{avg}")
      @log.info("Feed id: #{@feed.id}")
      @log.info("new products: #{stats[:new_products]}")      
      @log.info("product updates: #{stats[:product_updates]}")
      @log.info("price changes: #{stats[:price_changes]}")
      @log.info("new cats: #{stats[:new_cats]}")
      @log.info("new brands: #{stats[:new_brands]}")
      @log.info("product errors: #{stats[:product_errors]}")      
      pgs = ProductGenerationSummary.create(:feed_id => @feed.id, :new_products => stats[:new_products],
        :product_updates => stats[:product_updates], :new_cats => stats[:new_cats], :new_brands => stats[:new_brands],
        :product_errors => stats[:product_errors], :price_changes => stats[:price_changes])
      pgs.save!
      
      @stats = pgs
      return pgs
    end
    
    def create_product_from_csv_line(line)
      # Create a product from a line in a csv
                  
      # Process a single line of a product csv and turn it into a product
      csv = CSV.parse_line(line)

      # pass a row and a map of column_name => index and return a map of column => value
      product_map = get_data_from_row(csv)
                    
      # Create a product from a hash of column_name => value
      @product_generator.create_product(
        @feed.id,  
        product_map[Sku],
        product_map[ProductName],
        product_map[BrandName],
        product_map[Category],
        product_map[SubCategory],
        product_map[ProductGroup],
        product_map[RetailPrice],
        :small_image_url => product_map[ThumbUrl],
        :large_image_url => product_map[ImageUrl],
        :buy_url => product_map[BuyLink],
        :sale_price => product_map[SalePrice],
        :manufacturer_id => product_map[ManufacturerId]
      )
    end
    
    def get_data_from_row(row)
      # Get a hash of column to product data
      
      mapping = {}
                    
      # For each column stuff 
      Columns.each do |column|    
          
        # Find the index of the column we're looking for
        index = @column_mapping[column]
    
        throw NameError.new("Missing required field #{column} from row") if RequiredColumns.include?(column) and index.nil?
            
        # If there is data in the row use the row's data
        mapping[column] = index.nil? ? nil : row[index]      
      end
                        
      return mapping
    end
    
    def convert_seconds_to_time(seconds)
      total_minutes = seconds.to_i / 1.minutes
      seconds_in_last_minute = seconds - total_minutes.minutes.seconds
      return [total_minutes, seconds_in_last_minute]
    end
    
  end

  class ProductGenerator
    # This class creates product, feed category, and brand objects in our system
    
    attr_accessor :brands, :departments, :feed_categories, :stats
            
    def initialize(options = {})
              
      @log = Log4r::Logger['product_generator']
      @log.info("Start product generator")
              
      # Cache departments              
      @departments = {}
      Department.find(:all).each do |d|
        key = d.value
        @departments[key] = d
      end

      # Cache the categories and brands before processing to remove db calls
      @feed_categories = {}
      FeedCategory.find(:all).each do |c| 
        key = FeedCategory.get_unique_identifier(c.feed_id, c.feed_category, c.feed_subcategory, c.feed_product_group)
        @feed_categories[key] = c
      end

      # Cache brands
      @brands = {}      
      Brand.find(:all).each do |b| 
        
        # Get a key that canonicalizes the brand name so we remove dupes
        key = Brand.get_brand_key(b.name)

        # If there is a mapping set the key to that brand instead
        @brands[key] = b.mapped_to ? b.mapped_to : b 
      end
      
      # Set of summary variables used for logging
      @stats =  {
        :new_cats => 0,
        :new_brands => 0,
        :product_updates => 0,
        :new_products => 0,
        :product_errors => 0,
        :price_changes => 0
      }      
    end
    
    def create_product(feed_id, sku, product_name, brand_name, feed_category, feed_subcategory, 
      feed_product_group, retail_price, options = {})
            
      # Either create a new product or edit an existing one
      @log.debug("Process sku: #{sku}")

      product = nil

      # Wrap it all in a transaction
      Product.transaction do

        # Lookup the id for these and create or assign
        brand = get_brand(brand_name)
        feed_category = get_feed_category(feed_id, feed_category, feed_subcategory, feed_product_group)
        department = get_department(product_name, feed_category, feed_subcategory, feed_product_group)
        
        # If the product exists then update
        # NOTE: There is some total activerecord wackness going on here. It seems that
        # pulling data from the CSV file is actually pulling it as a CSV_CELL and not a 
        # native ruby object. Make sure to cast here so everything works
        product = Product.find_or_initialize_by_feed_id_and_sku(feed_id.to_i, sku.to_s)
                
        product.product_name = product_name
        product.small_image_url = options[:small_image_url]
        product.large_image_url = options[:large_image_url]
        product.buy_url = options[:buy_url]
        product.manufacturer_id = options[:manufacturer_id]
        
        # Set relations        
        product.feed_category = feed_category
        product.brand = brand
        product.department = department
        
        # We can pass in the product price created date for testing purposes..
        created_at = options[:created_at] || Time.zone.now
        
        # Make sure this is decimal
        retail_price = retail_price.to_d
                                                      
        if options[:sale_price].nil?
          # No sale price means use the retail price
          sale_price = retail_price
        else
          sale_price = options[:sale_price].to_d
        end
                      
        # Save the record so we can build associations
        
        if product.new_record? 
          # This is a new product
          @log.debug("Create new product. sku #{product.sku}")
          @stats[:new_products] += 1
          
          product.sale_price = sale_price
          product.retail_price = retail_price
          
          # New products are always eligible for notification
          # Note: new products have a previous_price value of 0.0
          product.price_changed_at = created_at
          product.product_prices.build(:price => product.sale_price, :created_at => created_at)
          
        else
          # This product already exists..
          @stats[:product_updates] += 1 
          @log.debug("Update product: sku #{product.sku}")
          
          # There are some cases where a merchant simply changes one price column
          # Only change the retail price if the new price is higher than a previous price.
          # Otherwise, we are using sale price to keep track of discounts
          if !options[:sale_price].nil?
            # Normal case. There is a sale_price
            product.retail_price = retail_price
          elsif options[:sale_price].nil? and retail_price > product.retail_price
            product.retail_price = retail_price 
          end
                                            
          # Keep track of previous sale price and update new price
          if sale_price != product.sale_price
            @stats[:price_changes] += 1               

            product.product_prices.build(:price => sale_price, :created_at => created_at)
            
            product.product_prices.length
            
            product.sale_price = sale_price
            product.price_changed_at = created_at
            product.previous_sale_price = product.sale_price
          end
        end
        
        product.save!
      end
      
      return product 
    end
            
    def get_feed_category(feed_id, feed_category, feed_subcategory, feed_product_group)
      # Get a category object from the cached categories by name
      # If the category doesn't exist then create it      
      identifier = FeedCategory.get_unique_identifier(feed_id, feed_category, feed_subcategory, feed_product_group)
      c = @feed_categories[identifier]
      
      if !c
        @stats[:new_cats] += 1
        c = FeedCategory.create!(:feed_category => feed_category, :feed_subcategory => feed_subcategory, 
          :feed_product_group => feed_product_group, :feed_id => feed_id, :value => identifier, :category_id => nil)
        @feed_categories[identifier] = c
      end             
      return c
    end
    
    def get_brand(name)
      # Get a brand. Use cache first..
            
      key = Brand.get_brand_key(name)
            
      # check the db just to make sure..
      b = @brands[key]
                        
      # if something in the cache exists return that
      unless b
        # Otherwise, the brand doesn't exist. Create it and add to the cache
        @log.debug "Create new brand: #{name}"
        @stats[:new_brands] += 1        
        b = Brand.create!(:name => name)
        @brands[key] = b # add to cache
      end
      
      return b
    end

    def get_department(product_name, feed_category, feed_subcategory, feed_product_group)
      value = Department.get_value(product_name, feed_category, feed_subcategory, feed_product_group)
      return @departments[value]
    end

  end
  
end
