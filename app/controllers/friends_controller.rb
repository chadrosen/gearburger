require 'email_veracity'
require 'user_inviter'

class FriendsController < ApplicationController

  before_filter :ensure_active
  
  # Turn off the authenticity token on ajax posts
  skip_before_filter :verify_authenticity_token, :only => [:get_friends]

  def invite_friends

    # TODO: move to template?
    # Default message for personal messages...
    @personal_message = <<-END
Hey there,

Your friend #{current_user.email} thinks you should check out Gear Burger. It will change the way you shop for outdoor gear.

http://www.gearburger.com/

Regards,
The Gear Burger
#{OPTIONS[:info_email]}
    END
    
    @invited_friends = UserInvite.find_all_by_user_id(current_user.id, :include => [:registered_user], 
      :order => "user_invites.created_at DESC")
  end

  def invite_friends_submit
    ui = Messaging::UserInviter.new    
    ui.invite_users(current_user, params[:friend], params)
    render :nothing => true
  end
  
  def get_friends
    service_name = params[:service_name] ? params[:service_name].strip : nil
    username = params[:username] ? params[:username].strip : nil
    password = params[:password] ? params[:password].strip : nil
    
    unless ["gmail", "yahoo", "hotmail"].index(service_name)
      render :json => {:result => "error", :msg => "invalid service"} and return
    end 
    
    # Test email address
    address = EmailVeracity::Address.new(username)
    
    if username.empty? or password.empty? or !address.valid?
      render :json => {:result => "error", :msg => "invalid_login" } and return 
    end
    
    begin
      contacts = Contacts.new(service_name, username, password).contacts
      contacts.sort! { |a,b| a[1].downcase <=> b[1].downcase } # sort by email
      render :json => { :result => "success", :contacts => contacts}
    rescue Contacts::AuthenticationError => ae
      render :json => { :result => "error", :msg => "invalid_login" }
    rescue GData::Client::CaptchaError => ce
      render :json => { :result => "error", :msg => "captcha error" }
    rescue Exception => e
      render :json => { :result => "error", :msg => e.message }      
    end
  end
    
end