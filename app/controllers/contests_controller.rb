class ContestsController < ApplicationController
  def index
        
    @contest = Contest.where(:active => true).first
    @captions = []
    
    @page = params[:page] ? params[:page].to_i : 1

    return if !@contest  # No need to do anything else..
        
    @captions = Caption.paginate(:page => @page, :per_page => 50, 
      :conditions => ["contest_id = ? AND users.state = ?", @contest.id, :active], :order => "vote_count DESC", 
      :include => [:user])
          
    # Check for a caption
    @caption = Caption.find_by_user_id_and_contest_id(current_user.id, @contest.id) if current_user
    
    # If no caption.. create a place holder
    @caption = Caption.new(:contest => @contest, 
      :description => "Vote for the best caption or submit your own. Most votes wins!") if @caption.nil?
    
    # Look for some votes
    @vote = Vote.find_by_cookie_and_contest_id(cookies[:abingo_identity], @contest.id) if cookies[:abingo_identity] 
    @vote = Vote.new(:contest => @contest) if @vote.nil?
    
    if current_user and current_user.state != :active:
      flash[:message] = "Your account must be active to participate in our contests"
    end
  end
  
end