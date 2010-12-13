Gearburger::Application.configure do

  # Settings specified here will take precedence over those in config/environment.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local = false
  config.action_controller.perform_caching             = true
    
  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Use memcache
  Rails.configuration.cache_store = :dalli_store

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Set the default action mailer host..
  OPTIONS[:site_url] = "www.gb.packethole.com"
  config.action_mailer.default_url_options = { :host => OPTIONS[:site_url] }

  OPTIONS[:full_feed_location] = File.join("/var/www/gearburger_staging/full_feeds")

  # The location of producct emails on disk
  OPTIONS[:product_email_location] = File.join("/var/www/gearburger_staging/shared/product_emails")

  # facebook stuff
  OPTIONS[:facebook_app_id] = 227423218563
  OPTIONS[:facebook_api_key] = "d37a85a9d91fc5e286a2a4062da1c047"
  OPTIONS[:facebook_secret_key] = "e2e59c1d2d1f126059fcdbc52fefd4dd"
  
  # Config options for s3
  OPTIONS[:s3_key] = "" 
  OPTIONS[:s3_secret] = ""
end