Gearburger::Application.configure do

  # Settings specified here will take precedence over those in config/environment.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local = false
  config.action_controller.perform_caching             = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  config.serve_static_assets = true
  
  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Enable threaded mode
  # config.threadsafe!

  # Set the default action mailer host..
  OPTIONS[:site_url] = "www.gearburger.com"
  config.action_mailer.default_url_options = { :host => OPTIONS[:site_url] }

  # Google account info used to interact with google APIs
  OPTIONS[:google_username] = "chadrosen@yahoo.com"
  OPTIONS[:google_password] = "fooooooo"
  OPTIONS[:google_api_key] = "ABQIAAAANYmh190Wqm135KBtAGEVPBT2yXp_ZAY8_ufC3CFXhHIE1NvwkxRCyBeQLUGsBwZokxEjKe5SmEk1bQ"

  # Facebook stuff
  OPTIONS[:facebook_one_time_token] = "CD05TJ"
  OPTIONS[:facebook_app_id] = 226546521327
  OPTIONS[:facebook_api_key] = "8b4b1f5d5a895f05d3d7d1f8eec516db"
  OPTIONS[:facebook_secret_key] = "c7c6c77ef9c13bc4a98940469416d145"
  
  # Config options for s3
  OPTIONS[:s3_key] = "" 
  OPTIONS[:s3_secret] = ""
end