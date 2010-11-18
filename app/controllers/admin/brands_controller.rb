module Admin

  class BrandsController < AdminController

    def index
                                        
      page = params[:page] || 1

      @inactive = params[:inactive] ? true : false
      @unpopular = params[:unpopular] ? true : false
      @name = params[:name]

      conditions = "active = #{!@inactive} AND popular = #{!@unpopular}"   
      conditions += "brands.name LIKE '%#{@name}%'" if @name and !@name.empty?
    
      @brands = Brand.paginate :page => page, :conditions => [conditions], :order => "brands.name ASC", 
        :per_page => 100        
    end
      
    def edit
      @brand = Brand.find(params[:id], :include => [:mapped_to])
      @users = BrandsUser.count(:conditions => { :brand_id => @brand.id })
      
      brands = Brand.find_all_by_active(true, :order => "name ASC").collect { |b| [b.name, b.id] }
      @brands = [["none", "none"]] + brands
      @mapped_to = @brand.mapped_to ? @brand.mapped_to.id : "none"
      
      @products = Product.count(:conditions => { :brand_id => @brand.id })
    end
    
    def popular
      @limit = params[:limit] ||  20
      @brands = Brand.popular_brands(:limit => @limit)
    end
  
    def update
      @brand = Brand.find(params[:id])
            
      # Map one brand to another brand for the purposes of product matching
      if params[:map_to]
        
        if params[:map_to] == "none"
          @brand.mapped_to = nil
          @brand.save!
        elsif params[:map_to] != "none"
          b = Brand.find(params[:map_to])
          Brand.map_brand(@brand, b)
        end
        
        return redirect_to(admin_brands_url)
      end
      
      if @brand.update_attributes(params[:brand])
        flash[:notice] = "Brand was successfully updated"
        return redirect_to(admin_brands_url)
      else
        render(:action => "edit")
      end      
    end
    
    def new
      @brand = Brand.new
    end
    
    def create
      @brand = Brand.create(params[:brand])
      unless @brand.save
        flash[:error] = "There was a problem saving the brand. Name must be unique"
        return render(:action => "new")
      end
      
      redirect_to(admin_brands_url)
    end

  end
end