class BaseMailer < ActionMailer::Base

  helper :application
        
  default :from => OPTIONS[:email_from], :return_path => OPTIONS[:return_path]
end
