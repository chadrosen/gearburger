#
# This file contains setting which are common to all environments.  Each environment may
# override these settings during its initialization or accept these defaults
#

OPTIONS = {} unless defined?(OPTIONS)

# Params for sending emails. See config/initializers/mail.rb
# Default is to use postfix. Dev mode uses gmail. Test mode doesn't send mail

# Use the same from address and return-path for all emails
OPTIONS[:email_from] = "Gear Burger Alerts <alert@gearburger.com>"
OPTIONS[:email_return_path] = "alert@gearburger.com"

# Internal email info
OPTIONS[:internal_email_to] = "info@gearburger.com"
OPTIONS[:internal_error_to] = "errors@gearburger.com"
OPTIONS[:internal_email_from] = "internal@gearburger.com"

# Email settings for prod and staging
OPTIONS[:action_mailer_deliver_method] = :smtp
OPTIONS[:email_address] = "smtp.sendgrid.net" 
OPTIONS[:email_port] = "25"
OPTIONS[:email_authentication] = :plain
OPTIONS[:email_username] = "chad@gearburger.com"
OPTIONS[:email_password] = "chadpw00"
OPTIONS[:email_domain] = "gearburger.com"
OPTIONS[:enable_starttls_auto] = false

# TODO: not sure if we use this anymore...
OPTIONS[:info_email] = "info@gearburger.com"

# The full feed download location
OPTIONS[:full_feed_location] = Rails.root.join("tmp", "full_feeds")

OPTIONS[:recaptcha_public_key] = "6Le7eAcAAAAAAOCcjjhB4585JIJTbJteMcQtPbq0"
OPTIONS[:recaptcha_private_key] = "6Le7eAcAAAAAAPdMo6rfwi15mDEwC4SUqU8s_OyC"

# Test google account info used to interact with google APIs.. The prod version is in the prod config
#OPTIONS[:google_username] = "chadrosen@hotmail.com"
OPTIONS[:google_username] = "chadrosen@yahoo.com"
OPTIONS[:google_password] = "fooooooo"
OPTIONS[:google_api_key] = "ABQIAAAANYmh190Wqm135KBtAGEVPBT2yXp_ZAY8_ufC3CFXhHIE1NvwkxRCyBeQLUGsBwZokxEjKe5SmEk1bQ"

# API info
OPTIONS[:twitter_consumer_key] = "ljmlRryNlPoJ9jXfQKdXqg"
OPTIONS[:twitter_consumer_secret] = "mlkDM41JuTFFrglC7hj81Bi8D0xXTTf7Thg8XVJi8"
OPTIONS[:twitter_access_token] = "39898253-7nrPcVfMrQQI4CD5gjDmjwh18OW43mGk1fSA33GjA"
OPTIONS[:twitter_access_secret] = "z2nQT4dBrCW9V1TwsFinM8a69bR1DBsaSjxuUItUiyk"

OPTIONS[:facebook_page_id] = 127166921453

# The location of producct emails on disk
OPTIONS[:product_email_location] = File.join(Rails.root.to_s, "tmp", "product_emails")

# Admin basic auth protection
OPTIONS[:admin_username] = "gbadmin" 
OPTIONS[:admin_password] = "gbpw00"