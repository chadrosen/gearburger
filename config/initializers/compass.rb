# Turn on rails compass integration for dev mode only. 
# This auto-compiles the stylesheets from app/stylesheets to public/stylesheets
if Rails.env == "development"
  require 'compass'
  require 'compass/app_integration/rails'
  Compass::AppIntegration::Rails.initialize!
end