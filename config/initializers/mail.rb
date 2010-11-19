# :smtp in most modes, :test in test mode 
ActionMailer::Base.delivery_method = OPTIONS[:action_mailer_deliver_method]

# Common settings
ActionMailer::Base.smtp_settings = {
    :address => OPTIONS[:email_address],
    :port => OPTIONS[:email_port],
    :domain => OPTIONS[:email_domain],
}

# Dev and test mode use gmail
if Rails.env.to_s == "development" || Rails.env.to_s == "test"
  ActionMailer::Base.smtp_settings[:enable_starttls_auto] = true
  ActionMailer::Base.smtp_settings[:authentication] = OPTIONS[:authentication]
  ActionMailer::Base.smtp_settings[:user_name] = OPTIONS[:email_user_name]
  ActionMailer::Base.smtp_settings[:password] = OPTIONS[:email_password]
end
