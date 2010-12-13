class MiscController < ApplicationController
              
  # Go ahead and cache these actions. No big deal to sweep them...
  # b/c brands and feeds don't change that often   
  caches_action :faq, :about, :invite_terms, :privacy
                               
  def faq
    feeds = Feed.where(:active => true).order("name ASC").all
    @feeds = feeds.collect { |f| f.name }
  end
  
  def about
    @brands = Brand.count(:conditions => {:active => true})
  end
            
end