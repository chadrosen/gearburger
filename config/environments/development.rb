# Settings specified here will take precedence over those in config/environment.rb
Gearburger::Application.configure do

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local = true
  config.action_view.debug_rjs                         = true
  config.action_controller.perform_caching             = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true
  
  config.serve_static_assets = true

  # Set the default action mailer host..
  OPTIONS[:site_url] = "localhost:3000"
  config.action_mailer.default_url_options = { :host => OPTIONS[:site_url] }

  # Internal email info
  OPTIONS[:internal_email_to] = "chadrosen@gmail.com"
  OPTIONS[:internal_error_to] = "chadrosen@gmail.com"

  OPTIONS[:use_tls] = true
  OPTIONS[:authentication] = :login
  OPTIONS[:email_user_name] = "alertburger@gearburger.com"
  OPTIONS[:email_password] = "alertburgerpw00"
  OPTIONS[:email_domain] = "gearburger.packethole.com"
  OPTIONS[:email_address] = "smtp.gmail.com"
  OPTIONS[:email_port] = 587

  # Facebook stuff
  OPTIONS[:facebook_one_time_token] = "EVJ2UZ"
  OPTIONS[:facebook_app_id] = 225955489319
  OPTIONS[:facebook_api_key] = "0a3d09575ec0586cc776c78a55489832"
  OPTIONS[:facebook_secret_key] = "c91150e9ccdb0d47054edde93cf582bb"
end