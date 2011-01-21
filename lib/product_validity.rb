module ProductValidity
       
  class VerifyProduct
    
    attr_accessor :stats
    
    def initialize(options = {})
      @log = Rails.logger
    end
                
    def validate_product!(product)
            
      # Check a product's image and sale price      
      begin
        result = valid_image?(product.small_image_url)
        vi = result[:success] == true ? true : false
      rescue
        @log.debug("image fail: #{product.small_image_url}")
        vi = false
      end
      
      begin
        result = valid_sale_price?(product.buy_url, product.sale_price)
        vsp = result[:success] == true ? true : false
      rescue
        @log.debug("sale fail: #{product.buy_url} #{product.sale_price}")
        vsp = false
      end
      
      @log.info("Result: #{product.id} image: #{vi} sale_price: #{vsp}")            
      product.update_attributes!(:valid_small_image => vi, :valid_sale_price => vsp)
    end
    
    def valid_image?(small_image_url)
      # Validate the image url, pull the result from the web and validate it
      return { :success => false, :message => "Error validating image" } unless validate_image(small_image_url)
      
      begin
        res = fetch(small_image_url)        
        return { :success => false, :message => "Invalid result code: #{res.code}" } unless res.code == "200"
      rescue
        return { :success => false, :message => "invalid response code fetching image" }
      end

      return { :success => true }
    end
        
    def validate_image(small_image_url)
      
      # Invalid url is always invalid
      unless small_image_url
        return { :success => false, :message => "Empty small image url" } 
      end
        
      if URI.extract(small_image_url).empty?
        return { :success => false, :message => "Invalid small image url" }
      end
      
      # Validate the url must end in image format 
      # Also, found that some urls have the word image and are valid
      if (small_image_url =~ /(\.png|\.jpg|\.gif|\.jpeg)$|(.*image.*)|(.*img.*)/i).nil?
        return { :success => false, :message => "Invalid image url suffix" }
      end
      
      return { :success => true }
    end
        
    def valid_sale_price?(buy_url, sale_price)
      # Get the html from the web and validate it

      # Invalid buy url is always invalid
      unless buy_url
        return { :success => false, :message => "Empty buy url" }
      end
      
      if URI.extract(buy_url).empty?
        return { :success => false, :message => "Invalid buy url" }
      end

      begin
        res = fetch(buy_url)
        unless res.code == "200"
          return { :success => false, :message => "sale price status code: #{res.code}" }
        end
      rescue
        return { :success => false, :message => "invalid response code fetching sale price" }
      end

      return { :success => true }
    end
    
    def validate_sale_price(html, sale_price)
      # Check a sale price string against some html

      # Pretty up the sale price into a valid regexp (2 decimal places)
      number_str = '%.2f' % sale_price.to_s
      regexp = Regexp.escape(number_str)

      # Search for the sale price in the response body. 
      # If it's not there then the product is invalid
      result = ( html =~ /(\D#{regexp}\D|^#{regexp}\D|\D#{regexp}$)/ ) 
      
      if result.nil?
        return { :success => false, :message => "Could not find sale regex in html" }
      else
        return { :success => true }
      end
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