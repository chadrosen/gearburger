module Admin

  class DepartmentsController < AdminController
    
    def index
      page = 1
      @departments = Department.paginate :page => page, :conditions => {}, 
        :order => "departments.name ASC", :per_page => 20
    end
    
    def edit
      @department = Department.find(params[:id])
    end
    
    def update
      @department = Department.find(params[:id])
      respond_to do |format|
        if @department.update_attributes(params[:department])
          flash[:notice] = "Department was successfully updated"
          format.html { redirect_to(admin_departments_url) }
          format.xml { head :ok }
        else
          format.html { render :action => "edit"}
          format.xml { render :xml => @department.errors, :status => :unprocessable_entity }
        end
      end
    end
    
  end
end
