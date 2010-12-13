# Be sure to restart your server when you modify this file.

#Gearburger::Application.config.session_store :cookie_store, :key => '_pre_3_0_branch_session'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Gearburger::Application.config.session_store :active_record_store

# Use dalli memcache store for sessions if memcache is set (prod and stage)
if Rails.configuration.cache_store == :dalli_store
  require 'action_dispatch/middleware/session/dalli_store'
  Rails.application.config.session_store :dalli_store, :namespace => 'sessions', 
    :key => '_foundation_session', :expire_after => 30.minutes
end