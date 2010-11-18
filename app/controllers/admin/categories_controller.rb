module Admin
  class CategoriesController < AdminController
    
    def index
      
      conditions = {}
      @show_inactive = params[:show_inactive]
      conditions[:active] = @show_inactive ? false : true
      
      page = params[:page]
      @categories = Category.paginate :page => page, :conditions => conditions, 
        :order => "categories.name ASC", :per_page => 50
    end
    
    def edit
      @category = Category.find(params[:id])
    end
    
    def update
      @category = Category.find(params[:id])
      if @category.update_attributes(params[:category])
        flash[:notice] = "Category was successfully updated"
        redirect_to(admin_categories_url)
      else
        render :action => "edit"
      end
    end
    
    def new
      @category = Category.new
    end
    
    def create
      category = Category.create(params[:category])
      category.save!
      redirect_to(admin_categories_url)
    end
    
  end
end