require 'stats'
module Admin

  class ClicksController < AdminController
      
    def index
      
      @click_type = params[:click_type]
      @email = params[:email]
      @source = params[:source]
      
      @start_date, @end_date = Stats::get_date_range_from_strings(:start_date => params[:start_date], 
        :end_date => params[:end_date])

      conditions = {
        :created_at => (@start_date.getutc...@end_date.getutc)
      }      
      
      # If email is included set the user_id
      if @email
        u = User.find_by_email(@email)
        conditions[:user_id] = u.id if u 
      end
      
      conditions[:click_type] = @click_type if @click_type and @click_type != "all"
      conditions[:source] = @source if @source and !@source.blank?
      conditions[:user_id] = params[:user_id] if params[:user_id]
      page = params[:page] || 1
      
      @results = Click.paginate :conditions => conditions, :page => page, :per_page => 50, 
        :order => "created_at DESC",  :include => [:user, :user_product_email]          
    end
    
    def show
      @click = Click.find(params[:id], :include => [:user])
    end
    
  end
end