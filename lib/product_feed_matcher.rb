module AlertGenerator

  class ProductFeedMatcher
        
    def initialize(options = {})
      @group_by = options[:group_by] || 3
      @limit = options[:limit] || 99
      @threshold = options[:threshold] || 0
      @email_save_path = options[:product_email_location] || OPTIONS[:product_email_location]
            
      # Create save path if it doesn't exist
      Dir.mkdir(@email_save_path, 777) unless File.exists? @email_save_path
      
      @batch_size = options[:batch_size] || 25 # Send X emails per batch
      @batch_wait = options[:batch_wait] || 30 # X seconds in between batches
      
      # Used for testing in scary environments like prod without actually sending emails
      @dry_run = options[:dry_run] == true ? true : false
    end
            
    def generate_emails
      # Get the matching emails and send them out
      emails_sent = 0 
      get_eligible_users.each do |u|
        User.transaction do
          
          # Get the products that match the user
          mps = get_matching_products(u)
          categories = make_category_array(mps, :group_by => @group_by)
                                        
          # Send notifications if there are matches...
          if mps.length > 0
            ProductNotificationMailer.product_price_change(u, categories).deliver unless @dry_run
            emails_sent += 1
          end
        end
      end
      
      # Keep track of how many emails we sent and how many total deals we found
      return emails_sent
    end
    
    def create_emails
      # Creates the emails and saves them to disk so we can send them later
      created = 0 
      get_eligible_users.each do |u|
        User.transaction do
          
          # Get the products that match the user
          mps = get_matching_products(u)
                    
          categories = make_category_array(mps, :group_by => @group_by)
                    
          next if mps.length == 0
    
          # Create email
          e = ProductNotificationMailer.product_price_change(u, categories)            

          # Save to disk
          file_name = File.join(@email_save_path, "#{u.email}_#{Time.zone.today}.email")
          dump = Marshal.dump(e)
          file = File.new(file_name,'w')
          file.write dump
          file.close

          created += 1
        end
      end
      
      # Keep track of how many emails we sent and how many total deals we found
      return created
    end
    
    def deliver_in_batches(options = {})
      
      date = options[:date] || Time.zone.today
      sent = 0
      errors = []
      
      # Get all of today's emails
      path = File.join(@email_save_path, "*_#{Time.zone.today}.email")
      file_names = Dir.glob(path)
            
      while !file_names.empty?
        
        # Take a slice of the files
        slice = file_names.slice!(0, @batch_size)
        
        # Send email of the emails
        slice.each do |fn| 
          
          begin
            # Don't let a single email jack up all the other emails...
            deliver_email(fn)
          rescue Exception => e
            errors << fn
          end
        end

        # Sleep after a batch
        sleep(@batch_wait) unless file_names.empty?        
      end
      
      return { :sent => 0, :errors => errors }
      
    end
    
    def deliver_email(email_file_path)
      # Deliver a Marshalled email on disk
   
      # Load the file
      f = File.new(email_file_path, "r")
    
      # Marshal the object from the file
      email = Marshal.load(f.read)
      f.close
    
      # Deliver the mail
      email.deliver
    
      # Finish by deleting the email
      File.delete(email_file_path)
    end
    
    def get_eligible_users(options = {})
      # Get all of the active users that want the email..
      
      # Get the day of week so we can make sure the user wants the email
      d = options[:date] ? Time.parse(options[:date]) : Time.zone.today
      dow = get_day_of_week(d)
      
      User.find(:all, :joins => [:email_day_preferences], 
        :conditions => {"users.state" => "active", "email_day_preferences.day_of_week" => dow})        
    end
    
    def get_day_of_week(date)
      return EmailDayPreference::DaysOfWeek[date.strftime("%w").to_i]
    end
    
    def get_matching_products(user, options = {})
      # Get a list of products matching a user's selections that
      # have a price change recently that is favorable
      
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
                                                                                            
      sql = "
      (SELECT
      pr.id,
      (pr.retail_price - pr.sale_price) / pr.retail_price as discount
      FROM
      	products as pr
        JOIN feed_categories as fc ON pr.feed_category_id = fc.id
      	JOIN categories_users as cu ON fc.category_id = cu.category_id
      	JOIN brands_users as bu ON pr.brand_id = bu.brand_id
      	JOIN departments_users as du ON pr.department_id = du.department_id
      	JOIN users as us ON (bu.user_id = us.id AND cu.user_id = us.id AND du.user_id = us.id)
      	JOIN brands as br ON br.id = bu.brand_id
      	JOIN categories as ca ON ca.id = cu.category_id
      	JOIN departments as de ON de.id = du.department_id
      WHERE
      	ca.active = TRUE
      	AND br.active = TRUE
      	AND de.active = TRUE
      	AND fc.active = TRUE
      	AND (pr.previous_sale_price = 0.0 OR pr.sale_price < pr.previous_sale_price)
      	AND pr.valid_sale_price = true
      	AND (pr.retail_price - pr.sale_price) / pr.retail_price >= #{min_discount}
      	AND pr.sale_price BETWEEN #{min_price} AND #{max_price}
      	AND pr.price_changed_at BETWEEN '#{sd.strftime("%Y-%m-%d %H:%M:%S")}' AND '#{ed.strftime("%Y-%m-%d %H:%M:%S")}'
      	AND us.id = #{user.id}
      )
      UNION
      (SELECT
        pr.id,
        (pr.retail_price - pr.sale_price) / pr.retail_price as discount
      FROM
        products as pr
        JOIN feed_categories as fc ON pr.feed_category_id = fc.id
        JOIN categories_users as cu ON fc.category_id = cu.category_id
      	JOIN brands_users as bu ON pr.brand_id = bu.brand_id
      	JOIN brands as br ON br.id = bu.brand_id
      	JOIN categories as ca ON ca.id = cu.category_id
      	JOIN users as us ON (bu.user_id = us.id AND cu.user_id = us.id)
      WHERE
        ca.active = TRUE
    	  AND br.active = TRUE
    	  AND fc.active = TRUE
        AND (pr.previous_sale_price = 0.0 OR pr.sale_price < pr.previous_sale_price)    	
      	AND (pr.retail_price - pr.sale_price) / pr.retail_price >= #{min_discount}
        AND pr.department_id IS NULL
        AND pr.valid_sale_price = true
        AND pr.sale_price BETWEEN #{min_price} AND #{max_price}      	
      	AND pr.price_changed_at BETWEEN '#{sd.strftime("%Y-%m-%d %H:%M:%S")}' AND '#{ed.strftime("%Y-%m-%d %H:%M:%S")}'
        AND us.id = #{user.id}
      ) LIMIT #{limit}
      "  
      
      # puts sql
      # chad test user id: 860352380
                  
      results = ActiveRecord::Base.connection.select_values(sql)
      
      # TODO: including category for now... 
      return Product.find(results, :include => [:category, :brand], 
        :order => "(retail_price - sale_price) / retail_price DESC")
    end

    # Turns the array of products into an array of arrays with [category_obj, [[prod_obj1, prod_obj2, ...]]]
    # Supported Options:
    # sort_by = :name will sort resultant array ascending by category name 
    #         = :number" will sort resultant array descending by number of products
    # group_by = x will group the array of products by the number passed in (default is to use the limit)
    # limit   = x will limit the number of products returned in each category (not the total amount of products)
    def make_category_array(products, options = {})
      sort_by = options[:sort_by] || :number
      limit = options[:limit] || 99
      group_by = options[:group_by] || limit
      
      cats = {}
      # Turn into general hash first
      products.each { |p|
        unless p.category.nil?
          if cats[p.category].nil?
            cats[p.category] = [p]
          else
            cats[p.category] = cats[p.category].push(p) 
          end
        end
      }
      
      # Handle limit and group by
      cats.each { |c, p|
        if (limit == 0) or (group_by == 0)
          cats[c] = [[]]
        else
          cats[c] = p.first(limit).in_groups_of(group_by,false)
        end
      }
      
      # Then sorting
      if sort_by == :number
        result = cats.to_a.sort { |x,y| y[1][0].length <=> x[1][0].length }        
      else
        result = cats.to_a.sort { |x,y| x[0].name <=> y[0].name }
      end

      return result
    end

  end

  class DealFinder
    
    def initialize(options = {})
      @min_retail_discount = options[:min_retail_discount] || 0.4
      @min_average_discount = options[:min_average_discount]
      @min_category_discount = options[:min_category_discount]
    end

    def find_deals(options = {})
      # Run for last 7 days by default
      sd = options[:start_date] || Date.today - 7.days
      ed = options[:end_date] || Date.today

      products = Product.get_changed_products(:start_date => sd.to_s, :end_date => ed.to_s, :threshold => @min_retail_discount)

      categories = {}
      tests = []
      results = []

      products.each do |p|
        test = {:product => p}
        test[:pass] = 1

        unless @min_category_discount.nil?
          category_discount_count = 0
          category = p.category
          # Handle category caching
          unless category.nil?
            if categories[category.id].nil?
              category.populate_average_discount
              categories[category.id] = category
            end

            # Test for difference from category average price
            if p.discount >= categories[p.category.id].average_discount + @min_category_discount
              test[:pass] = result[:pass]*1
              category_discount_count += 1
            else
              test[:pass] = result[:pass]*0
            end
          end
        end

        unless @min_average_discount.nil?
          average_discount_count = 0
          # Get product price history
          p.populate_price_history        
          # Test for difference from average price
          if (p.avg_price - p.sale_price) / p.avg_price > @min_average_discount
            test[:pass] = result[:pass]*1
            average_discount_count += 1
          else
            test[:pass] = result[:pass]*0
          end
        end
        
        tests.push(test)
      end

      # Return all products that pass
      tests.each do |t|
        if t[:pass]
          results.push(t[:product])
        end
      end

      return results
    end

  end

end
