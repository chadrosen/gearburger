class CaptionsController < ApplicationController

  before_filter :protect_login, :only => [:create]

  def create

    # Users must be active to submit a caption
    redirect_to(:back) and return if current_user.state != :active

    c = "Vote for the best caption or submit your own. Most votes wins!"
    
    if !params[:caption] || !params[:caption][:description] || params[:caption][:description] == c
      redirect_to(:back) and return
    end
    
    Caption.create!(:contest_id => params[:contest_id], :description => params[:caption][:description], :user => current_user)
    
    respond_to do |format|
      format.json { render :json => {:result => "success" } and return }
      format.html do |html| 
        flash[:message] = "Thanks for submitting a caption. Make sure to tell your friends to vote!"
        redirect_to(:back)
      end
    end
  end  
end
