# This file is used by Rack-based servers to start the application.
require ::File.expand_path('../config/environment',  __FILE__)

# Change the default stylesheet link to be under tmp/stylesheets instead of public/stylesheets
# This lets us use sass generated css in staging and prod on heroku
use Rack::Static, :urls => ["/stylesheets/"], :root => "tmp"

run Gearburger::Application