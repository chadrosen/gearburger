# This configuration file works with both the Compass command line tool and within Rails.
# Require any additional compass plugins here.
project_type = :rails
project_path = Compass::AppIntegration::Rails.root
http_path = "/"
css_dir = "public/stylesheets" # Compile stylesheets to the public/stylesheets dir
sass_dir = "app/stylesheets"
environment = Compass::AppIntegration::Rails.env

puts "Compass install"

puts Compass.configuration.sass_options
Compass.configuration.sass_options = { :never_update => true }
puts Compass.configuration.sass_options
puts "Compass post install"