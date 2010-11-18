# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController

  def new
    @next_url = params[:u]
  end

  def create
    
    logout_keeping_session!
    user = User.authenticate(params[:email], params[:password])
        
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
                  
      # Set the session user
      self.current_user = user
      
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      
      # Remove any lingering flash errors
      flash[:error] = ""
  
      # If not session[return_get] send the user to the home page
      redirect_to(user_url(user)) and return unless session[:return_get]

      # Show the error on posts
      flash[:error] = "You clicked on a button or submitted a form. Please try submitting again." unless session[:return_get]
      
      # Redirect back to the session return to or user home
      redirect_to(session[:return_to] || user_url(user))
      
      # Clear stuff
      session[:return_to] = session[:return_get] = nil
      return
      
    else
      # No user.. back to login
      flash[:error] = "There was a problem with your email or password"
      @email = params[:email]       
      @next_url = params[:u]
      render(:action => "new") and return
    end

    # Weird case.. 404
    render :file => "#{Rails.root.to_s}/public/404.html", :status => 404 and return            
  end

  def destroy
    logout_killing_session!
    redirect_back_or_default('/')
  end

end