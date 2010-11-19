require 'product_feed_matcher'
require 'product_generator'
require 'sendgrid'
require 'sales_processor'

desc "This task is called by the Heroku cron add-on"
task :cron => :environment do

  # TODO: Figure out error handling in the cron
  # TODO: Figure out result emails
  # TODO: Write function that keeps track of time

  if Time.now.hour == 0 # run at midnight
    
    vp = ProductValidity::VerifyProduct.new
    fm = AlertGenerator::ProductFeedMatcher.new
    
    
    Rails.logger.info "Run midnight crons"
        
    #stats = []
    
    Feed.find_all_by_active(true).each do |f|
      
      # Download the gzip feed file from avantlink
      pg = AlertGenerator::AvantlinkFeedParser.new(f)
      r = pg.download_feed(OPTIONS[:full_feed_location])
      
       # Process the feed
      pg.process_product_feed(r)
      
      #stats << pg.stats #Update the stats
            
      #begin      
      #rescue Exception => e
        # If there is an exception log it and email us
        # ProductNotificationMailer.deliver_product_generator_error(f, e)
      #end
    end
    
    # Update gearburger peeps with the results...
    # ProductNotificationMailer.deliver_product_generator_results(stats)

    # Get changed products and validate them
    products = Product.get_changed_products(options)  
    vp.validate_products!(products)
    
    # Send the emails after everything is done
    sent = pm.generate_emails

    # TODO: Figure out if I want to pre-generate and then email
    # Send the product emails for valid products
    # created = fm.create_emails
    
    Rails.logger.info "Midnight crons complete"
     
 elsif Time.now.hour == 22
   # Misc system functions that can be run really at any time
   
   # Clean out users who have invalid info from sendgrid
   cie = Sendgrid::ClearInvalidEmails.new
   cie.clear_emails
   
   # Get sales from the last 3 days
   sp = AlertGenerator::SalesProcessor.new
   sp.start(:start_date => Date.today - 3, :end_date => Date.today)
   
   # Clear out the breaks from users if they expire today
   User.clear_break_users(Time.zone.now.utc)
 end
 
 # Placeholder in case I need this functionality
 #if Time.now.hour % 4 == 1 # run every four hours
 #   puts "4 am"
 #end
 
end

# OLD
# 0 0 * * * /usr/local/bin/ruby /var/www/gearburger/current/script/product_generator -eproduction -i
# 0 2 * * * /usr/local/bin/ruby /var/www/gearburger/current/script/product_price_mailer -eproduction -tcreate -l33 -u
# 0 4 * * * /usr/local/bin/ruby /var/www/gearburger/current/script/product_price_mailer -eproduction -tdeliver
# 0 1 * * * /usr/local/bin/ruby /var/www/gearburger/current/script/product_validator -l 3000 -eproduction

# 10 0 * * * /usr/local/bin/ruby /var/www/gearburger/current/script/sales_processor -eproduction
# 30 0 * * * /usr/local/bin/ruby /var/www/gearburger/current/script/user_break_clearer -eproduction
# 0 22 * * * /usr/local/bin/ruby /var/www/gearburger/current/script/sendgrid -eproduction

# TODO: Do I need to even do this?
# 0 2 * * * cd /var/www/gearburger/current && /usr/local/bin/rake db:delete_old_sessions RAILS_ENV=production hours_ago=5