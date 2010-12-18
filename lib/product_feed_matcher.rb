module AlertGenerator

  class ProductFeedMatcher
        
    def initialize(options = {})
      @group_by = options[:group_by] || 3
            
      # Used for testing in scary environments like prod without actually sending emails
      @dry_run = options[:dry_run] == true ? true : false
    end
                
    def generate_emails
      # Get the matching emails and send them out
      emails_sent = 0 
      
      User.transaction do
        User::get_eligible_users.each do |u|
          # Get the products that match the user
          mps = u.matching_products
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
      products.each do |p|
        unless p.category.nil?
          cats[p.category] = cats[p.category] ? cats[p.category].push(p) : [p]          
        end
      end
      
      # Handle limit and group by
      cats.each do |c, p|
        if (limit == 0) or (group_by == 0)
          cats[c] = [[]]
        else
          cats[c] = p.first(limit).in_groups_of(group_by,false)
        end
      end
      
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
      tests.each { |t| results.push(t[:product]) if t[:pass] }
        
      return results
    end

  end

end
