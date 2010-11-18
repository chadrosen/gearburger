module Admin

  class ContestsController < AdminController
    
    def index
      @contests = Contest.all
      
      @logged_in = current_user ? true : false
      @ucc = cookies[:ucc]
      @hash = current_user ? Digest::MD5.hexdigest(current_user.id.to_s) : nil
    end
      
    def edit
      @contest = Contest.find(params[:id])
      @contest.start_time = @contest.start_time.getlocal
      @contest.end_time = @contest.end_time.getlocal
      
    end
    
    def update
      @contest = Contest.find(params[:id])      
      respond_to do |format|
      
        @contest.update_attributes(params[:contest])
        @contest.start_time = Time.zone.parse(params[:contest][:start_time])
        @contest.end_time = Time.zone.parse(params[:contest][:end_time])
        
        if @contest.valid?
          flash[:notice] = "Contest was successfully updated"
          format.html { redirect_to(admin_contests_url) }
          format.xml { head :ok }
        else
          format.html { render :action => "edit"}
          format.xml { render :xml => @contest.errors, :status => :unprocessable_entity }
        end
      end
    end

    def new
      @contest = Contest.new
      @contest.start_time = Time.zone.now.strftime("%Y-%m-%d 00:00:00")
      @contest.end_time = (Time.zone.now + 604800).strftime("%Y-%m-%d 23:59:59") # Default is 7 days
    end
  
    def create
      contest = Contest.create(params[:contest])
      contest.start_time = Time.zone.parse(params[:contest][:start_time])
      contest.end_time = Time.zone.parse(params[:contest][:end_time])
      contest.save!
      redirect_to(admin_contests_url)
    end
  
  end
end