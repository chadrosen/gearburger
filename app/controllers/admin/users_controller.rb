require 'product_feed_matcher'
module Admin

  class UsersController < AdminController
      
    def index
      
      @search = params[:search] ? params[:search].strip : ""
      @state = params[:state]
      @news = params[:send_newsletter] ? true : false
      @limit = params[:limit] ? params[:limit].to_i : 50 
      conditions = []
      conditions << "state = '#{@state}'" if @state && @state != "all"      
      conditions << "send_newsletter = True" if @news      
      conditions << "email LIKE '%#{params[:search]}%'" unless @search.empty?
      c = conditions.join(" AND ")
                    
      # If user wants CSV
      send_data(User.find(:all, :conditions => c).to_csv(:only => [:email])) and return if params[:csv]
                    
      @users = User.find(:all, :order => "created_at DESC", :limit => @limit, :conditions => c)
      @total = User.count(:conditions => c)
    end
    
    def show
      @user = User.where(:id => params[:id]).includes([:brands, :categories, :departments, :campaign]).first
      @cats = @user.categories.collect { |c| c.name }.join(" ")
      @depts = @user.departments.collect { |d| d.name }.join(" ")
      @brands = @user.brands.length
      
      @email_prefs = @user.email_day_preferences.collect { |ep| ep.day_of_week.to_s }.join(", ")
    end
                
    def activate
      user = User.find(params[:id])
      user.activate!
      redirect_to(admin_user_url(user))
    end

    def deactivate
      user = User.find(params[:id])
      user.deactivate!
      redirect_to(admin_user_url(user))
    end
  
    def login
      # TODO: PROTECT ME
    
      user_id = params[:id]
        
      if user_id.blank?
        redirect_back_or_default("/")
      else
        user = User.find(user_id)
        if user
          self.current_user = user
          redirect_to(user_url(user))
        end      
      end
    end
    
    def reasons
      @users = User.where(["deactivation_reason != ''"]).order("deleted_at DESC").all
    end

    def giftcards
      @invites = params[:invites] || 1
      @count = User.count(:group => [:referral_id], :conditions => ["state = 'active' AND referral_id IS NOT NULL"],
        :having => ["count_all >= ?", @invites], :order => "count_all DESC")
      
      # Create a hash of user_id => user object
      @user_hash = Hash[*User.find(@count.keys).collect { |u| [u.id, u] }.flatten]
    end
    
    def invited_users
      @user = User.find(params[:id])
      @users = @user.registered_invites(:order => "created_at DESC")
    end
  
  end

end