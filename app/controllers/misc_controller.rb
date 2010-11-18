class MiscController < ApplicationController
                                
  def sitemap
    @title = "#{@title}. Gear Burger sitemap"
    @meta_desc = "The Gear Burger site map. Use this page to help find your way around the Gear Burger website."
  end
                 
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