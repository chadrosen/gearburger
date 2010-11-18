class UserMailer < BaseMailer
    
  def signup_notification(user)
    @user = user
    @activation_code = user.activation_code
    mail(:to => user.email, :subject => 'Please activate your new account')
  end
    
  def lost_password(user, password)
    @user = user
    @password = password
    mail(:to => user.email, :subject => "Gear Burger password")
  end
  
  def user_invitation(user, to_address, options = {})
    # Invitation email
        
    # Clean up personal message a bit before sending it through..
    personal_message = options[:personal_message] ? options[:personal_message].strip : nil
        
    @invitor = user.email
    @invitee = to_address
    @personal_message = personal_message # personal message is optionals
    
    mail(:to => to_address, :bcc => ["info+user_invite@gearburger.com"], 
      :subject => "#{user.email} suggests you check out Gear Burger")
  end  
end
