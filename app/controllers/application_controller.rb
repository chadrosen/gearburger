# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'robots'
require 'authenticated_system'

class ApplicationController < ActionController::Base
  
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
    
  # Let's set the user's timezone if they're logged in..
  before_filter :set_time_zone, :set_layout_data
    
  # Handle routing errors by throwing a 404 and logging something small instead of the entire stack
  rescue_from(ActionController::RoutingError) {
    logger.fatal "Invalid url requested: #{request.fullpath}"
    render :file => "#{Rails.root.to_s}/public/404.html", :layout => false, :status => 404
  }
      
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  def get_fb_user
    # Make a call to the facebook api for the current user...
    
    # Get the facebook cookie so we can get the user's email
    fb_params = get_facebook_cookie    
    return unless fb_params
    
    begin
      uri = URI.parse(URI.encode("https://graph.facebook.com/me?access_token=#{fb_params['access_token']}"))
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)

      result = JSON.parse(response.body)
            
      return result["error"] ? nil : result
    rescue Exception => e
      # TODO: log
      return
    end        
  end

  def set_layout_data
    # Set a common set of data that may be used in every template
    @errors = []            
  end
  
  def set_time_zone
    # If there is a user defined in the session and their tz is defined use it
    Time.zone = @current_user.time_zone if @current_user && @current_user.time_zone
  end
  
  def protect_login
    # Add the original url if it exists to the url
    unless logged_in?
      # Found this in http://rubyglasses.blogspot.com/2008/04/redirectto-post.html
      # TODO: It's possible I have this code somewhere.. need to look
      session[:return_get] = request.get?
      session[:return_to] = request.get? ? request.request_uri : request.env["HTTP_REFERER"]
      redirect_to(login_url)
    end
  end
  
  def ensure_active
    # Make sure the user is logged in and active
    return protect_login unless logged_in?
    redirect_to(root_url) unless current_user.state == "active"
  end
          
end
