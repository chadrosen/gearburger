module Admin

  class CaptionsController < AdminController
    def index
      @contest = Contest.find(params[:contest_id])      
      @captions = Caption.where(:contest_id => params[:contest_id]).includes([:user]).order("vote_count DESC")      
    end
    
    def edit
      @caption = Caption.find(params[:id], :include => [:user])
    end

    def update
      @caption = Caption.find(params[:id])
      respond_to do |format|
        if @caption.update_attributes(params[:caption])
          flash[:notice] = "Caption was successfully updated"
          format.html { redirect_to(admin_contest_captions_url(@caption.contest_id)) }
        else
          format.html { render :action => "edit"}
        end
      end
    end
    
  end
end