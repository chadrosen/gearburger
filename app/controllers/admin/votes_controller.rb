module Admin
  class VotesController < AdminController
    def index
      @caption = Caption.find(params[:caption_id])      
      @votes = Vote.find(:all, :order => "created_at DESC",  
        :conditions => {:caption_id => params[:caption_id]})
    end 
    
    def destroy
      v = Vote.find(params[:id], :include => [:caption])
      # If the vote was valid then reduce the caption vote_count by one
      v.destroy
      redirect_to :back
    end
    
    def edit
      @vote = Vote.find(params[:id], :include => [:caption])
    end
    
    def update
      vote = Vote.find(params[:vote][:id], :include => [:caption])

      # increment/decrement vote count if the is_valid field is different
      v = params[:vote][:is_valid] == "0" ? false : true
      
      Vote.transaction do
         
        if vote.is_valid && !v
          # we're changing a vote to be invalid: decrement the caption count
          vote.is_valid = false
          Caption.decrement_counter(:vote_count, vote.caption_id)
          Caption.increment_counter(:invalid_vote_count, vote.caption_id)          
        elsif !vote.is_valid && v
          # we're changing a vote to be valid: increment the caption count
          vote.is_valid = true
          Caption.increment_counter(:vote_count, vote.caption_id)
          Caption.decrement_counter(:invalid_vote_count, vote.caption_id)
        end
      
        vote.reason = params[:vote][:reason]
        vote.save!
      end
      
      redirect_to(admin_caption_votes_url(vote.caption.id))
    end
    
  end
end