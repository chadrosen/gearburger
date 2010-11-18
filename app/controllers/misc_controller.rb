class MiscController < ApplicationController
                 
  def faq
    @title = "#{@title}. Gear Burger FAQ"
    @meta_desc = "The page contains frequently asked questions about Gear Burger."
    feeds = Feed.find(:all, :conditions => {:active => true}, :order => "name ASC")
    @feeds = feeds.collect { |f| f.name }
  end
  
  def about
    @title = "#{@title}. About Gear Burger"
    @meta_desc = "This page contains information about the creators of Gear Burger."
    @brands = Brand.count(:conditions => {:active => true})
  end
            
end