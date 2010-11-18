module Admin
  class FriendsController < AdminController
    
    def index      
      @friends = Friend.find(:all)
    end
    
    def edit
      @friend = Friend.find(params[:id])
    end
    
    def update
      @friend = Friend.find(params[:id])
      respond_to do |format|
        if @friend.update_attributes(params[:friend])
          flash[:notice] = "friend was successfully updated"
          format.html { redirect_to(admin_friends_url) }
          format.xml { head :ok }
        else
          format.html { render :action => "edit"}
          format.xml { render :xml => @friend.errors, :status => :unprocessable_entity }
        end
      end
    end
    
    def new
      @friend = Friend.new
    end
    
    def create
      friend = Friend.create(params[:friend])
      friend.save!
      redirect_to(admin_friends_url)
    end
    
  end
end