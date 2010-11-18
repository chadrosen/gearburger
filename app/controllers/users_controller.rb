require 'email_veracity'
require 'product_feed_matcher'

class UsersController < ApplicationController
  
  # Protect every action using login except for the actions below
  before_filter :protect_login, :only => [:show, :toggle_newsletter, :brands,
    :brands_submit, :categories, :categories_submit, :departments, :departments_submit,
    :resend_activation_email, :deactivate_account, :reactivate_account, 
    :signup_complete, :sale_spot, :account_preferences, :account_preferences_submit]
            
  # Pre-populate the signup pages
  before_filter :get_departments, :only => [:signup, :departments, :create]
  before_filter :get_categories, :only => [:signup, :create]
  before_filter :already_logged_in, :only => [:new, :signup, :create]
  before_filter :tracking_params, :only => [:new, :signup]
                    
  def new    
    @title = "#{@title}. Get started"
    @meta_desc = "Get started on Gear Burger by creating your account. Select brands and categories you're interested in and we'll notify you when we find a match."
    @products = Product.get_products_by_params(:per_page => 3, :min_price => 37.0, :valid_sale => true)    
  end
  
  def fb_login
    # Login or connect a user in our db with facebook
    
    fb_user = get_fb_user
    
    return redirect_to(:back) unless fb_user

    # Get the user with the fb_user_id
    user = User.find_by_fb_user_id(fb_user["id"])

    if user
      self.current_user = user
      return redirect_to(root_url)
    end

    # Look in the database for a user with the facebook email
    user = User.find_by_email(fb_user["email"])
    
    if user
      # If that user exists update them with the fb_user_id
      user.fb_user_id = fb_user["id"]
      user.save!
      self.current_user = user
      return redirect_to(root_url)
    end

    # No user found.. Send them to signup categories
    flash[:error] = "We could not find your account. Please register or login with your email address."
    redirect_to(login_url)         
  end
  
  def signup    
    @title = "#{@title}. Select categories"
    @meta_desc = "Select the categories of gear that you're most interested in. We'll use these categories when notifying you of a match."
                                
    # do this so the time select stuff works correctly
    @email = "Enter Your Email Address"
    @selected_d = []
    @selected_c = []
    
    if request.post?
      
      fb_user = get_fb_user

      # Get the params
      @email = fb_user ? fb_user["email"] : params[:email]
      @selected_d = params[:departments] ? params[:departments].keys.collect { |d| d.to_i } : []
      @selected_c = params[:categories] ? params[:categories].keys.collect { |c| c.to_i } : []
      first_name = fb_user ? fb_user["first_name"] : nil
      last_name = fb_user ? fb_user["last_name"] : nil
      fb_user_id = fb_user ? fb_user["id"] : nil
                  
      if fb_user

        # The fb_user_id and email cannot already exist in the db
        u = User.find_by_fb_user_id(fb_user_id)
        if u
          self.current_user = u
          return redirect_to(root_url)
        end

        u = User.find_by_email(@email)
        if u
          self.current_user = u
          return redirect_to(root_url)
        end

      else

        if !valid_email?(@email) or User.find_by_email(@email)                                    
         flash[:error] = "Please enter a valid email address"
         return render(:action => :signup)
        end

        unless verify_recaptcha(:private_key => OPTIONS[:recaptcha_private_key])      
          flash[:error] = "Invalid captcha results. Please try again"
          return render(:action => :signup)
        end

      end

      # More validation
      if params[:departments].nil? or params[:departments].empty?
        flash[:error] = "Please select at least one department"
        return render(:action => :signup)
      end

      # More validation
      if params[:categories].nil? or params[:categories].empty?
        flash[:error] = "Please select at least one category"
        return render(:action => :signup)
      end

      u = User.register(
        @email,
        :first_name => first_name,
        :last_name => last_name,
        :fb_user_id => fb_user_id,
        :referral_url => session[:referral_url],
        :ip_address => request.remote_ip, 
        :user_agent => request.user_agent,
        :categories => @selected_c,
        :departments => @selected_d)

      # Clear this stuff
      session[:campaign_id] = nil
      session[:referral_url] = nil

      self.current_user = u

      # Send the user email..
      UserMailer.signup_notification(u).deliver

      return redirect_to(signup_complete_url)
    
    end
      
  end
                
  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?    
    
    case
    when (!params[:activation_code].blank?) && user && user.state != "active"
      
      # Activate the user
      user.activate!
            
      # Set the user in the session
      flash[:notice] = "Congrats! Your account is active."
      self.current_user = user
      redirect_to(user_url(current_user))      
      
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_to(new_user_url)
    else 
      flash[:error]  = "Invalid activation code. Maybe you've already activated. Try signing in."
      redirect_to(new_user_url)
    end
  end
    
  def deactivate_account_submit
    
    if params[:reason]
      current_user.deactivation_reason = params[:reason]
      current_user.save!
    end
        
    current_user.deactivate!
    redirect_to(user_url(current_user))    
  end
  
  def reactivate_account
    current_user.state = "active"
    current_user.deleted_at = nil
    current_user.save!
    flash[:notice] = "Your account has been reactivated and will start to receive alerts again"
    redirect_to(user_url(current_user))    
  end
                
  def change_password_submit
    
    # Change the user's password
    current_user.password = params[:password]
    current_user.password_confirmation = params[:confirm_password]
              
    if current_user.valid? && current_user.save
      flash[:notice] = "Password changed succesfully"
      return redirect_to(user_url(current_user))
    end

    @errors = current_user.errors.full_messages
    render :action => :change_password
  end
      
  def show
    @categories = current_user.categories(:order => "name ASC")
    @departments = current_user.departments(:order => "name ASC")
    @brands =  BrandsUser.count(:conditions => {:user_id => current_user.id })

    @alerts = []
    
    @invited_friends = UserInvite.count(:conditions => { :user_id => current_user.id })
    @registered_friends = User.count(:conditions => { :referral_id => current_user.id, :state => "active" })
    @eligible_gift_cards = @registered_friends / 10    
  end
           
  def resend_activation_email
    
    # Re-send the user activation email
    redirect_to(home_url, :status => 404) and return unless current_user.state == "pending"
    
    begin
      UserMailer.signup_notification(current_user).deliver
    rescue SocketError => se
      # Couldnt send the email for some reason.. No internet access :)
      flash[:error] = "There was error sending your activation email. Please contact error@gearburger.com"
    end
  end
  
  def toggle_newsletter
     User.find(current_user.id).toggle!("send_newsletter")
     render :json => {:result => "success"}
  end
  
  def lost_password
    @title = "#{@title}. Lost password."
    @meta_desc = "Did you lose your password? The page allows you to email yourself a new password."
  end
  
  def lost_password_submit
    flash[:error] = "Email address is required" and redirect_to(lost_password_url) if params[:email].empty?

    user = User.find_by_email(params[:email])
    UserMailer.lost_password(user, user.reset_password!).deliver if user 
    flash[:notice] = "An email was sent to your address. Please follow the instructions within the email to reset your password"

    redirect_to(lost_password_url)
  end
        
  def brands    
    
    @cats = Category.find_all_by_active(true, :order => "name ASC")
    
    @letters = [''].concat(('a'..'z').to_a)
    brands = Brand.find_all_by_active(true)
    @brands = Brand.group_by_alpha(brands)
    @selected = current_user.brands.map { |d| d.id }    
  end
  
  def brands_submit
    ids = params[:brands] ? params[:brands].keys.collect { |c| c } : []
    current_user.brands = []
    
    # Add new data
    current_user.brands = Brand.find(ids)
    current_user.save!
            
    redirect_to(user_url(current_user))
  end
  
  def categories
    categories = Category.find_all_by_active(true, :order => "name ASC")
    @cat_list = categories.in_groups_of(2, false).collect { |g| g }
    @selected = current_user.categories.map { |d| d.id }    
  end
  
  def categories_submit
    
    ids = params[:categories] ? params[:categories].keys.collect { |c| c } : []

    # Delete existing data
    current_user.categories = []
    
    # Add new data
    current_user.categories = Category.find(ids)
    current_user.save!
    redirect_to(user_url(current_user))
  end
  
  def departments
    @selected = current_user.departments.map { |d| d.id }
  end
  
  def departments_submit
    
    ids = params[:departments] ? params[:departments].keys.collect { |c| c } : []       
    current_user.departments = [] # Set back to empty
        
    # Add new data
    current_user.departments = Department.find(ids)
    current_user.save!    
    
    redirect_to(user_url(current_user))
  end
              
  def more_gear
    
    params[:valid_sale] = true
    
    products = Product.get_products_by_params(params)
    render :json => {:products => products}
  end
              
  def gear_bin
    @page = params[:page] ? params[:page].to_i : 1
    
    params[:valid_sale] = true
    
    @products = ActiveSupport::JSON.encode(Product.get_products_by_params(params).as_json)
    @uc = current_user.categories.collect { |c| c.id }    
    @categories = Category.find_all_by_active(true, :order => "name ASC")
    @depts = Department.find_all_by_active(true, :order => "name ASC")
    
    @ud = current_user.departments.collect { |d| d.id }
  end
  
  def account_preferences
    @user = current_user 
  end
    
  def account_preferences_submit
        
    begin
      
      User.transaction do
      
        current_user.update_attributes(params[:user])      
        current_user.min_discount = params[:min_discount] if params[:min_discount]
                        
        unless current_user.valid?
          flash[:error] = current_user.errors.full_messages.join(", ")
          return redirect_to(account_preferences_url)
        end
                
        prefs = [] 
        EmailDayPreference::DaysOfWeek.each { |d| prefs << EmailDayPreference.new(:day_of_week => d) if params[d] }
        if prefs.length == 0
          flash[:error] = "Please select at least one day to receive emails"
          return redirect_to(account_preferences_url)
        end
        
        # Go ahead and delete old preferences so new ones can be made correctly
        EmailDayPreference.delete_all(["user_id = ?", current_user.id])
        current_user.email_day_preferences = prefs
                                        
        unless valid_email?(params[:user][:email])
          flash[:error] = "Please enter a valid email address"
          return redirect_to(account_preferences_url)
        end
            
        email = params[:user][:email]
            
        # No need to change if it's the same email
        if email != current_user.email
          current_user.email = email
          current_user.state = "pending"
          current_user.activation_code = User.make_token

          address = EmailVeracity::Address.new(email)
          unless address.valid?
            flash[:error] = "Please supply a valid email address"
            return redirect_to(account_preferences_url)
          end
      
          # Check the db for the email.. Don't want to send to an existing user..
          if User.find_by_email(email)
            flash[:error] = "Please supply a valid email address"
            return redirect_to(account_preferences_url)
          end
      
          UserMailer.signup_notification(current_user).deliver
      
        end
              
        current_user.save!
      end

    rescue SocketError => se
      # Couldnt send the email for some reason.. No internet access :)
      flash[:error] = "There was error sending your activation email. Please contact error@gearburger.com"
    end
    
    flash[:notice] = "Your information has been succesfully changed"
    redirect_to(account_preferences_url)
  end
                
  def gearguide
    friends = Friend.find_all_by_active(true, :order => "created_at DESC")
    @friends = friends.in_groups_of(3, false).collect { |g| g }
  end
    
  def clear_breather
    current_user.clear_breather!
    flash[:notice] = "Welcome back! You will start receiving emails again based on your account preferences."
    redirect_to(take_a_breather_url)
  end
  
  def take_a_breather_submit
    # Make sure it's a valid break option
    return redirect(root_url) unless User::BreakOptions.include?(params[:break_end])
    current_user.take_a_break!(Time.zone.now, params[:break_end]) 
    redirect_to(root_url)
  end
        
protected

  def tracking_params
    # Grab some params from the url and request referer unless they are already set
    
    # Keep track of the campaign id if it exists in the params
    session[:campaign_id] = params[:cid] unless session[:campaign_id]
                              
    # Keep track of referral for analytics later
    if request.referer and (request.referer =~ /^http:\/\/#{request.host}/).nil? and session[:referral_url].nil? 
      session[:referral_url] = request.referer
    end
    
  end

  def already_logged_in
    redirect_to(user_url(current_user)) if current_user
  end

  def valid_email?(email)
        
    return false if !email or email.blank?
    
    # FB proxy mail addresses seem to return false
    return true if email.include?("proxymail.facebook.com")
        
    # User email veracity to validate email
    address = EmailVeracity::Address.new(email)
    
    return address.valid?
  end
  
  def get_categories
    @categories = Category.find_all_by_active(true, :order => "name ASC")
    @cat_list = @categories.in_groups_of(2, false).collect { |g| g }
  end
  
  def get_departments
    @departments = Department.find_all_by_active(true)
    @department_list = @departments.in_groups_of(3, false).collect { |g| g }
  end
            
end