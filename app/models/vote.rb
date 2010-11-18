class Vote < ActiveRecord::Base

  def after_create    
    # Update the count on the caption
    Caption.increment_counter(:vote_count, self.caption_id) if self.is_valid
    Caption.increment_counter(:invalid_vote_count, self.caption_id) if !self.is_valid
  end
  
  def before_destroy
    Caption.decrement_counter(:vote_count, self.caption_id) if self.is_valid
    Caption.decrement_counter(:invalid_vote_count, self.caption_id) if !self.is_valid
  end

  belongs_to :caption
  belongs_to :contest
  belongs_to :user
    
  def self.create_vote(caption_id, browser_cookie, flash_cookie, options = {})

    caption = Caption.find(caption_id)

    valid, reason = is_vote_valid?(caption.contest_id, browser_cookie, flash_cookie)
        
    # Create the vote regardless of it being is_valid
    vote = Vote.create!(:contest_id => caption.contest_id, :caption_id => caption_id, 
      :is_valid => valid, :reason => reason, :user_agent => options[:user_agent],
      :ip_address => options[:ip_address], :cookie => browser_cookie, :flash_cookie => flash_cookie)    
    return vote    
  end

  def self.is_vote_valid?(contest_id, browser_cookie, flash_cookie)
        
    # Browser and flash cookie always required
    return false, "no browser cookie" if !browser_cookie
    return false, "no flash cookie" if !flash_cookie
                        
    # if there is a flash cookie make sure it is equal to the browser cookie
    return false, "flash cookie #{flash_cookie} != browser cookie #{browser_cookie}" if flash_cookie != browser_cookie
  
    # Only one vote per cookie / contest
    return false, "duplicate cookie id for contest" if Vote.exists?(:cookie => browser_cookie, :contest_id => contest_id)

    # Only one vote flash cookie per contest
    return false, "duplicate flash cookie id for contest" if Vote.exists?(:cookie => flash_cookie, :contest_id => contest_id)
    
    return true, nil    
  end

end
