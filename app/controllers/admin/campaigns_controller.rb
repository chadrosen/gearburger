module Admin
  class CampaignsController < AdminController
    
    def index      
      @campaigns = Campaign.order("created_at DESC")
    end
    
    def edit
      @campaign = Campaign.find(params[:id])
    end
    
    def update
      @campaign = Campaign.find(params[:id])
      if @campaign.update_attributes(params[:campaign])
        flash[:notice] = "campaign was successfully updated"
        redirect_to(admin_campaigns_url)
      else
        render :action => "edit"
      end
    end
    
    def new
      @campaign = Campaign.new
    end
    
    def create
      campaign = Campaign.create(params[:campaign])
      campaign.save!
      redirect_to(admin_campaigns_url)
    end
    
  end
end