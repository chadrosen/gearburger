# This file is used by Rack-based servers to start the application.
require ::File.expand_path('../config/environment',  __FILE__)

Sass::Plugin.options[:never_update] = true

run Gearburger::Application