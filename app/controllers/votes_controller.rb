class VotesController < ApplicationController

  def create
                          
    Vote.create_vote(params[:caption_id], cookies[:abingo_identity], params[:fc], 
      :user_agent => request.user_agent, :ip_address => request.remote_ip)
          
    respond_to do |format|
      format.json { render :json => {:result => "success" } and return }
      format.html do |f|
        flash[:message] = "Thanks for voting! We're calculating the results. Be sure to check back later."
        redirect_to(:back)
      end
    end
  end
    
end
