# Turn on rails compass integration for dev mode only (IE not heroky)
# This auto-compiles the stylesheets from app/stylesheets to public/stylesheets
if ENV["RAILS_ENV"] == "development"
  puts "compass install"
  puts "compass install"
  puts "compass install"
  puts "compass install"
  puts "compass install"
  puts "compass install"
  puts "compass install"
  puts "compass install"
  puts "compass install"
  puts "compass install"
  puts "compass install"

  require 'compass'
  require 'compass/app_integration/rails'
  Compass::AppIntegration::Rails.initialize!
end