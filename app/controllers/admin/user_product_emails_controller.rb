module Admin

  class UserProductEmailsController < AdminController
    def index
      
      @start_date, @end_date = Stats::get_date_range_from_strings(:start_date => params[:start_date], 
         :end_date => params[:end_date])
               
      # TODO: Definitely a DRY way to do this
      if params[:email] and !params[:email].empty?
        @email = params[:email]
        c = ["user_product_emails.created_at BETWEEN ? AND ? AND users.email = ?", @start_date.getutc, @end_date.getutc, params[:email]]
      else
        c = ["user_product_emails.created_at BETWEEN ? AND ?", @start_date.getutc, @end_date.getutc]
      end

          
      @results = UserProductEmail.find(:all, :conditions => c, :order => "user_product_emails.created_at DESC", :include => [:user])
    end
    
    def show      
      @upe = UserProductEmail.find(params[:id], :include => [:user])
    end
    
    def email_user
      # Email someone a user product email
      
      upe = UserProductEmail.find(params[:upe_id])
      
      if params[:email].nil? or params[:email].empty?
        flash[:error] = "Please enter an email address"
      else
        flash[:notice] = "Message delivered for to #{params[:email]}"
        u = User.find_by_email(params[:email])
        ProductNotificationMailer.product_price_change(u, upe.products).deliver
      end
      redirect_to(:back)
    end
    
  end
end