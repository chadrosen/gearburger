module ProductValidity
  
  class VerifyProduct
    
    attr_accessor :stats
    
    def initialize(options = {})
      @log = Rails.logger
      @stats = reset_stats
    end
    
    def reset_stats
      @stats = {
        :valid_images => 0, 
        :invalid_images => 0, 
        :valid_prices => 0, 
        :invalid_prices => 0,
        :total_products => 0,
        :started_at => Time.zone.now,
        :ended_at => nil,
        :total_time => nil,
        :avg_time => nil
      }      
    end
    
    def update_stats(valid_image, valid_sale_price)
      @stats[:total_products] += 1
      valid_image ? @stats[:valid_images] += 1 : @stats[:invalid_images] += 1
      valid_sale_price ? @stats[:valid_prices] += 1 : @stats[:invalid_prices] += 1
    end
    
    def stats_complete
      @stats[:ended_at] = Time.zone.now
      @stats[:total_time] = @stats[:ended_at] - @stats[:started_at]
      @stats[:avg_time] = @stats[:total_time] / @stats[:total_products]
    end
    
    def validate_products!(products)
      @log.info("Verify #{products.length} products")
      reset_stats
      products.each { |p| validate_product!(p) }
      stats_complete
      @log.info("Validation complete")
    end
    
    def validate_all!
      # Validate all products in the db
      validate_products!(Product.find(:all))
    end
    
    def validate_changed_products!(start_date, end_date)
      # Validate all products in the db
      p = Product.find(:all, :conditions => { :price_changed_at => (start_date...end_date)})
      validate_products!(p)
    end
       
    def validate_product!(product)
            
      # Check a product's image and sale price
      vi = valid_image?(product.small_image_url)
      vsp = valid_sale_price?(product.buy_url, product.sale_price)
      
      @log.info("Result: #{product.id} image: #{vi} sale_price: #{vsp}")
      @log.debug("sale fail: #{product.buy_url} #{product.sale_price}") unless vsp
      @log.debug("image fail: #{product.small_image_url}") unless vi
      
      update_stats(vi, vsp)
      
      product.update_attributes!(:valid_small_image => vi, :valid_sale_price => vsp)
    end
    
    def valid_image?(small_image_url)
      # Validate the image url, pull the result from the web and validate it
      return false unless validate_image(small_image_url)
      
      begin
        res = fetch(small_image_url)
        return res.code == "200"
      rescue
        return fail("invalid response code fetching image") 
      end
      
    end
        
    def validate_image(small_image_url)
      
      # Invalid url is always invalid
      return fail("Empty small image url") unless small_image_url

      return fail("Invalid small image url") if URI.extract(small_image_url).empty?
      
      # Validate the url must end in image format 
      # Also, found that some urls have the word image and are valid
      if (small_image_url =~ /(\.png|\.jpg|\.gif|\.jpeg)$|(.*image.*)|(.*img.*)/i).nil?
        return fail("Invalid image url suffix")
      end
      
      return true
    end
    
    def fail(message)
      @log.debug(message)
      return false
    end
    
    def valid_sale_price?(buy_url, sale_price)
      # Get the html from the web and validate it

      # Invalid buy url is always invalid
      return fail("Empty buy url") unless buy_url
      
      return fail("Invalid buy url") if URI.extract(buy_url).empty?

      begin
        res = fetch(buy_url)
        return fail("sale price status code: #{res.code}") unless res.code == "200"
        return validate_sale_price(res.body, sale_price)
      rescue
        return fail("invalid response code fetching sale price")
      end

    end
    
    def validate_sale_price(html, sale_price)
      # Check a sale price string against some html

      # Pretty up the sale price into a valid regexp (2 decimal places)
      number_str = '%.2f' % sale_price.to_s
      regexp = Regexp.escape(number_str)

      # Search for the sale price in the response body. 
      # If it's not there then the product is invalid
      result = ( html =~ /(\D#{regexp}\D|^#{regexp}\D|\D#{regexp}$)/ ) 
      
      return fail("Could not find sale regex in html") if result.nil?
            
      return true
    end
    
    def fetch(uri_str, limit = 10)
      # You should choose better exception.
      raise ArgumentError, 'HTTP redirect too deep' if limit == 0

      u = URI.parse(uri_str)
      response = Net::HTTP.get_response(u)
      if response.kind_of? Net::HTTPRedirection or response.kind_of? Net::HTTPServiceUnavailable
        
        # Some of these 'location' headers are fucked and just have absolute paths. Try to fix them
        if (response['location'] =~ /^http:\/\/.*/i).nil?
          location = "http://#{u.host}#{response['location']}"
        else
          location = response['location']
        end
        
        fetch(location, limit - 1)        
      elsif response.kind_of? Net::HTTPError 
        raise Exception, "HTTP Error"
      else
        response
      end
    end
    
  end
  
end