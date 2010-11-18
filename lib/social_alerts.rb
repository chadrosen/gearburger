#!/usr/bin/env ruby 
require 'rubygems'
require 'twitter'

module AlertGenerator
    
  class ProductPriceChangeAlert
    
    def initialize(options = {})
      @limit = options[:limit] || 3
      @test = options[:test] || false
      
      @sp = SocialAlerts.new(options)
    end
    
    def send_alert
      
      products = Product.get_changed_products()
      
      # Can't continue if there are no products with changes
      return unless products.length > 0

      # Get the list of brand names
      all_brands = products.map { |p| p.brand.name }
      all_brands.uniq!

      # Get a random slice of the brands      
      random_slice = all_brands.sort_by { rand }.slice(0...@limit)

      # Get the message that we're going to send out
      message = get_message(products.length, all_brands.length, random_slice)
      
      # Broadcast to the world if there's a message to see
      @sp.broadcast_all(message)
    end
    
    def get_message(product_count, total_brand_count, brands)
      # Get the end message that we're sending out to the social networks..
      
      # Deals plural
      deals = product_count > 1 ? "deals" : "deal"
      
      # A pretty string of brand names
      brand_string = brands.length > 1 ? brands.join(', ') : brands[0]
      message = "#{product_count} new #{deals} from #{brand_string}"

      # Add message and remainder info
      remainder = total_brand_count - brands.length
      if remainder > 0
        brand_plural = remainder == 1 ? "brand" : "brands"
        message = "#{message} and #{remainder} other #{brand_plural}"
      end

      # add gb
      "#{message} http://www.gearburger.com"
    end
       
  end
    
  class SocialAlerts
    
    attr_accessor :clients
    
    def initialize(options = {})
      #@clients = [FacebookClient.new(options), TwitterClient.new(options)]
      @clients = [TwitterClient.new(options)]

    end
    
    def broadcast_all(message)
      @clients.each { |c| c.broadcast(message) }
    end
        
  end
  
  class SocialClient
    
    attr_accessor :client
    
    def initialize(options = {})
    end
    
    def broadcast(message)
    end    
  end
  
  class TwitterClient < SocialClient
    
    def initialize(options = {})
      consumer_token = options[:twitter_consumer_token] || OPTIONS[:twitter_consumer_token]
      consumer_secret = options[:twitter_consumer_secret] || OPTIONS[:twitter_consumer_secret]
      access_token = options[:twitter_access_token] || OPTIONS[:twitter_access_token]
      access_secret = options[:twitter_access_secret] || OPTIONS[:twitter_access_secret]
            
      oauth = Twitter::OAuth.new(consumer_token, consumer_secret)
      oauth.authorize_from_access(access_token, access_secret)
      @client = Twitter::Base.new(oauth)
    end
    
    def broadcast(message)
      @client.update(message)
    end
    
  end
  
  class FacebookClient < SocialClient
    # http://cleanair.highgroove.com/articles/2009/07/19/how-to-update-a-facebook-page-status-using-the-facebook-api
    # http://facebooker.rubyforge.org/    
    # http://tech.karolzielinski.com/publish-post-of-facebook-page-wall-as-a-page-not-a-user-python-facebook-rest-api
    def initialize(options = {})
      token = options[:facebook_token] || OPTIONS[:facebook_one_time_token]
      @client = Facebooker::Session.create
      @client.auth_token = token
    end
    
    def broadcast(message, options = {})
      target = options[:target_id] || OPTIONS[:facebook_page_id]
      @client.post("facebook.stream.publish", :message => message, :uid => target)
    end
  end
  
end
