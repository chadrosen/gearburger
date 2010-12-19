# Turn on rails compass integration for dev mode only (IE not heroky)
# This auto-compiles the stylesheets from app/stylesheets to public/stylesheets

if Rails.env.production?
  Compass.configuration.sass_options = { :never_update => true }
  Sass::Plugin.options[:never_update] = true 
else
  require 'compass'
  require 'compass/app_integration/rails'
  Compass::AppIntegration::Rails.initialize!
end