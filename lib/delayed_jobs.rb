require 'product_feed_matcher'
require 'product_generator'
require 'sales_processor'
require 'product_validity'
require 'sendgrid'

module DelayedJobs
  
  class ValidProductJob
    # Uses delayed job plugin to initialize a sales processor and download the report
  
    attr_accessor :product_id, :options
  
    def initialize(product_id, options = {})
      @product_id = product_id
      @options = options
    end
  
    def perform
      vp = ProductValidity::VerifyProduct.new
      p = Product.find(@product_id)      
      vp.validate_product!(p)
    end    
   end
  
  class ProductEmailJob
    # Uses delayed job plugin to initialize a product feed matcher, find matches, and send email
    attr_accessor :options

    def initialize(options = {})
      @options = options
    end

    def perform
      pfm = AlertGenerator::ProductFeedMatcher.new(@options)
      pfm.generate_emails
    end    
  end

  class ClearEmailJob
    # Uses delayed job plugin to initialize a sales processor and download the report
    attr_accessor :options

    def initialize(options = {})
      @options = options
    end

    def perform
      # Clean out users who have invalid info from sendgrid
      cie = Sendgrid::ClearInvalidEmails.new
      cie.clear_emails
    end    
  end

  class SaleProcessorJob
  # Uses delayed job plugin to initialize a sales processor and download the report
    attr_accessor :options

    def initialize(options = {})
      @options = options
    end

    def perform
      options ||= {}
      sp = AlertGenerator::SalesProcessor.new(@options)
      sp.start(@options)
    end    
  end

  class FeedProcessorJob
    # Download the gzip feed file from avantlink and process it
    attr_accessor :feed_id, :options
  
    def initialize(feed_id, options = {})
      @feed_id = feed_id
      @options = options
    end
  
    def perform
      # TODO: Make this handle different feed typess generically
      pg = AlertGenerator::AvantlinkFeedParser.new(@feed_id, @options)
      pg.run
    end
  end

  class UserRegisterEmail
    # Send the user a registration email
    
    attr_accessor :user_id
    
    def initialize(user_id, options = {})
      @user_id = user_id
    end
    
    def perform
      u = User.find(@user_id)
      UserMailer.signup_notification(u).deliver
    end
  end
  
  class UserInviteEmail
    # Invite a user's friends
    
    attr_accessor :user_id, :email, :message
    
    def initialize(user_id, email, message, options = {})
      @user_id = user_id
      @email = email
      @message = message
    end
    
    def perform
      user = User.find(@user_id)
      UserMailer.user_invitation(user, email, :personal_message => message).deliver
    end
  end
  
  class UserLostPassword
    # Send lost password email
    
    attr_accessor :email
    def initialize(email, options = {})
      @email = email
    end
    
    def perform
      user = User.find_by_email(email)
      if user
        password = user.reset_password!
        UserMailer.lost_password(user, password).deliver
      end
    end
  end

end