class MiscController < ApplicationController
                 
  def faq
    feeds = Feed.find(:all, :conditions => {:active => true}, :order => "name ASC")
    @feeds = feeds.collect { |f| f.name }
  end
  
  def about
    @brands = Brand.count(:conditions => {:active => true})
  end
            
end