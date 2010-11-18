

desc "This task is called by the Heroku cron add-on"
task :cron => :environment do

  if Time.now.hour == 0 # run at midnight
    Rails.logger.info "Run midnight crons"
    
  end


 if Time.now.hour % 4 == 0 # run every four hours
   puts "4 am"
 end
end

# OLD
# 0 0 * * * /usr/local/bin/ruby /var/www/gearburger/current/script/product_generator -eproduction -i
# 0 2 * * * /usr/local/bin/ruby /var/www/gearburger/current/script/product_price_mailer -eproduction -tcreate -l33 -u
# 0 4 * * * /usr/local/bin/ruby /var/www/gearburger/current/script/product_price_mailer -eproduction -tdeliver
# 10 0 * * * /usr/local/bin/ruby /var/www/gearburger/current/script/sales_processor -eproduction
# 0 2 * * * cd /var/www/gearburger/current && /usr/local/bin/rake db:delete_old_sessions RAILS_ENV=production hours_ago=5
# 30 0 * * * /usr/local/bin/ruby /var/www/gearburger/current/script/user_break_clearer -eproduction
# 0 1 * * * /usr/local/bin/ruby /var/www/gearburger/current/script/product_validator -l 3000 -eproduction
# 0 22 * * * /usr/local/bin/ruby /var/www/gearburger/current/script/sendgrid -eproduction