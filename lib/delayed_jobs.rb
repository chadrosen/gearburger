require 'product_feed_matcher'
require 'product_generator'
require 'sales_processor'
require 'sendgrid'

module DelayedJobs
  
  class TestJob
    
    def perform
      puts "foo"
    end
  end

  class ProductEmailJob
    # Uses delayed job plugin to initialize a product feed matcher, find matches, and send email
    attr_accessor :options


    def initialize(options = {})
      @options = options
    end

    def perform
      pfm = ProductFeedMatcher.new(@options)
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
      sp = SalesProcessor.new(@options)
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

end