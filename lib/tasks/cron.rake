require 'delayed_jobs'

desc "This task is called by the Heroku cron add-on"
task :cron => :environment do

  # TODO: Figure out error handling in the cron
  # TODO: Figure out result emails
  # TODO: Write function that keeps track of time
        
  if Time.now.hour == 1 
    Rails.logger.info "Run 1am crons"
        
    # Download and process all feeds
    Feed.find_all_by_active(true).each do |f|
      Delayed::Job.enqueue DelayedJobs::FeedProcessorJob.new(f)
    end
    
  elsif Time.now.hour == 3
    Rails.logger.info "Run 3am crons"
    
    # Check the validity of all products
    Product.get_changed_products.each do |p|
      Delayed::Job.enqueue DelayedJobs::ValidProductJob(p)
    end
     
 elsif Time.now.hour == 22
   # Misc system functions that aren't specifically time of day dependent
   
   Delayed::Job.enqueue DelayedJobs::ClearEmailJob.new
   
   # Run sales processor job
   Delayed::Job.enqueue DelayedJobs::SaleProcessorJob.new(:start_date => Date.today - 3, :end_date => Date.today)
  
   # TODO: Make this a delayed job?
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