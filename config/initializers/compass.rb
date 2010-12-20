# Turn on rails compass integration for dev mode only (IE not heroky)
# This auto-compiles the stylesheets from app/stylesheets to public/stylesheets
# Only use the compass stuff in dev
if Rails.env.development?
  require 'compass'
  require 'compass/app_integration/rails'
  Compass::AppIntegration::Rails.initialize!
end