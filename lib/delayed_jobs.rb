require 'product_feed_matcher'
require 'product_generator'
require 'sales_processor'
require 'sendgrid'

module DelayedJobs

  class ProductEmailJob < Struct.new(:options)
    # Uses delayed job plugin to initialize a product feed matcher, find matches, and send email

    def perform
      options ||= {}
      pfm = ProductFeedMatcher.new(options)
      pfm.generate_emails
    end    
  end

  class ClearEmailJob < Struct.new(:options)
    # Uses delayed job plugin to initialize a sales processor and download the report

    def perform
      # Clean out users who have invalid info from sendgrid
      cie = Sendgrid::ClearInvalidEmails.new
      cie.clear_emails
    end    
  end

  class SaleProcessorJob < Struct.new(:options)
  # Uses delayed job plugin to initialize a sales processor and download the report

    def perform
      options ||= {}
      sp = SalesProcessor.new(options)
      sp.start(options)
    end    
  end

  class FeedProcessorJob < Struct.new(:feed, :options)
    # Download the gzip feed file from avantlink and process it
  
    def perform
      options ||= {}
      # TODO: Make this handle feeds generically
      pg = AlertGenerator::AvantlinkFeedParser.new(feed, options)
      r = pg.download_feed(OPTIONS[:full_feed_location], options)
      pg.process_product_feed(r) # Process the feed
    end
  end

end