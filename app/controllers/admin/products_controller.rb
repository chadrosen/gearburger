module Admin

  class ProductsController < AdminController
    
    def index
            
      @brands = Brand.find_all_by_active(true, :order => "name ASC")
      #@categories = Category.find_all_by_active(true, :order => "name ASC")
      @departments = Department.find_all_by_active(true, :order => "name ASC")
      
      # TODO: allow search
      @product_name = params[:product_name]
      c = []
      c << "products.brand_id = #{params[:brand_id]}" if params[:brand_id]        
      #c << "categories.id = #{params[:category_id]}" if params[:category_id]
      c << "products.department_id = #{params[:department_id]}" if params[:department_id]
      c << "product_name LIKE '%#{params[:product_name]}%'" if params[:product_name]
                                        
      @products = Product.find(:all, :order => "product_name ASC",
        :include => [:feed_category, :feed, :category, :brand, :department],
        :conditions => c.join(" AND "), :limit => 50)
    end
  
    def show
      @product = Product.find(params[:id], :include => [:feed_category, :category])      
    end
    
    def feed_results
      page = params[:page] || 1
      @start_date, @end_date = Stats::get_date_range_from_strings(:start_date => params[:start_date], 
        :end_date => params[:end_date])
      @results = Product.paginate :per_page => 50, :conditions => ["feed_id = ?", params[:id]], 
        :include => [:feed], :order => "updated_at DESC", :page => page
    end
    
    def user_emails
      pm = AlertGenerator::ProductFeedMatcher.new
      users = pm.get_eligible_users
      @user_emails = []
      users.each do |u|
        @user_emails << u if pm.get_matching_products(u).length > 0
      end      
    end
    
    def validation_results
      
      @start_date, @end_date = Stats::get_date_range_from_strings(:start_date => params[:start_date], 
        :end_date => params[:end_date])
      
      @limit = params[:limit] || 100
      
      @vsp = params[:valid_sale_price] ? true : false
      @vsi = params[:valid_small_image] ? true : false
            
      sql = "price_changed_at BETWEEN ? AND ? AND valid_sale_price = #{@vsp} and valid_small_image = #{@vsi}"
            
      page = params[:page] || 1
      @products = Product.paginate :conditions => [sql, @start_date.getutc, @end_date.getutc], 
        :page => page, :per_page => @limit
    end
  end
end