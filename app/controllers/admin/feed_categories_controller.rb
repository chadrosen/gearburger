module Admin
  class FeedCategoriesController < AdminController
    def index
                  
      @limit = params[:limit] || 100
      @show_inactive = params[:show_inactive] ? true : false
      @feed_category = params[:feed_category] ? params[:feed_category].strip : ""
      @feed_subcategory = params[:feed_subcategory] ? params[:feed_subcategory].strip : "" 
      @feed_product_group = params[:feed_product_group] ? params[:feed_product_group].strip : ""
      
      conditions = []
      
      if !params[:category_id] or params[:category_id] == "null"
        conditions << "category_id IS NULL"
        @c_filter_select = "null"
      elsif params[:category_id] == "all"        
        @c_filter_select = "all"
      else
        conditions << "category_id = #{params[:category_id]}"
        @c_filter_select = params[:category_id].to_i
      end
      
      # If feed category search specified default a bunch of stuff
      conditions << "feed_category LIKE '%#{@feed_category}%'" unless @feed_category.empty?
      conditions << "feed_subcategory LIKE '%#{@feed_subcategory}%'" unless @feed_subcategory.empty?
      conditions << "feed_product_group LIKE '%#{@feed_product_group}%'" unless @feed_product_group.empty?
      conditions << "feeds.active = true"
      conditions << "feed_categories.active = #{!@show_inactive}"

      c = Category.find_all_by_active(true, :order => "name ASC") 
      @c = [["null", "null"]] + c.collect { |c| [ c.name, c.id ] }
      @c_filter = [["all", "all"]] + @c

      @count = FeedCategory.count(:conditions => conditions.join(" AND "), :include => [:category, :feed])
                              
      q = FeedCategory.where(conditions.join(" AND ")).order("category_id ASC, feed_category ASC, feed_subcategory ASC, feed_product_group ASC")
      fcs = q.includes([:feed, :category]).limit(@limit).all  
    end     
    
    def multi_update
      # Update multiple feed categories at the same time      
      unless params[:feed_category_id]
        flash[:error] = "You must select at least one feed category"
        return redirect_to(admin_feed_categories_url)
      end
            
      fcs = FeedCategory.find(params[:feed_category_id])
      fcs.each { |f| f.update_attributes!(:category_id => params[:category_id]) }
      
      flash[:notice] = "Category succesfully changed"
      
      redirect_to(:back)
    end
    
    def edit
      @f = FeedCategory.find(params[:id], :include => [:feed, :category])
      #c = Category.find(:all, :conditions => {:active => true})
      c = Category.where(:active => true).all
      @c = [nil] + c.collect { |c| [ c.name, c.id ] }
    end
    
    def update
      @f = FeedCategory.find(params[:id])
      
      if @f.update_attributes(params[:feed_category])
        flash[:notice] = "Feed Category was successfully updated"
        redirect_to(admin_feed_categories_url)
      else
        c = Category.where(:active => true).all
        @c = [nil] + c.collect { |c| [ c.name, c.id ] }
        format.html { render :action => "edit"}
      end
    end
  
  end
end