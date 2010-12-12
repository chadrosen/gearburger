require 'email_veracity'
require 'delayed_jobs'

module Messaging
  
  class UserInviter
      
      def initialize(options = {})
        @max_attempts = options[:max_attempts] || 3
      end
      
      def invite_users(user, emails, options = {})
        # A little pre-processing..
        
        # TODO: I believe there is a better way to do this..
        if emails.class == String
          delim = emails.index(",") ? "," : "\n"
          emails = emails.split(delim)           
        end
                  
        emails.each { |e| e.strip! }
        emails.uniq!        
                
        # Send the emails
        emails.each { |e| invite_user(user, e, options) }
      end
      
      def invite_user(user, email, options = {})
        
        return if user.email == email # No need to send to the sender..
                
        return if user.state != "active"
        
        # don't email to an existing user..
        return if User.find_by_email(email)
        
        # Make sure the email is valid
        address = EmailVeracity::Address.new(email)
        return unless address.valid?
                                                          
        begin
          # Create new row if it doesn't exist..
          ui = UserInvite.find_or_initialize_by_user_id_and_email_address(user.id, email)

          return if ui.attempts >= @max_attempts
          
          ui.attributes = { :state => "sent", :sent_at => Time.zone.now}
          ui.attempts += 1
          ui.save!

          # Send the user email through a delayed job
          Delayed::Job.enqueue DelayedJobs::UserInviteEmail.new(user.id, email, options[:personal_message])
                    
          return ui
          
        rescue Exception => e
          ui.state = "error"
          ui.error_msg = e.message
          ui.save!
          return nil
        end        
      end
  end  
end