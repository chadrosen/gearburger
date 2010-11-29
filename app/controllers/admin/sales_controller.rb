module Admin

  class SalesController < AdminController
      
    def index
      @start_date, @end_date = Stats::get_date_range_from_strings(:start_date => params[:start_date], 
        :end_date => params[:end_date])          
      page = params[:page] || 1
      conditions = {
        :transaction_time => (@start_date.getutc...@end_date.getutc)
      }
      conditions[:user_id] = params[:user_id] if params[:user_id]
      
      @results = Sale.paginate :conditions => conditions,
        :page => page, :per_page => 50, :order => "transaction_time DESC", :include => [:click, :user]
    end
    
    def show
      @sale = Sale.find(params[:id], :include => [:click, :user])
    end
        
  end
end