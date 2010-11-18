require 'product_generator'

module Admin
    
  class FeedsController < AdminController
    
    def index
      @today_time = (Time.zone.now - 1.days).strftime("%Y-%m-%d %H:%I:%M")
      active = (params[:active] and params[:active] == "Inactive") ? false : true
      @active = params[:active]
      @feeds = Feed.where(:active => active).includes([:most_recent_run]).order("created_at DESC").all
    end
    
    def edit
      @feed = Feed.find(params[:id])
    end
    
    def update
      @feed = Feed.find(params[:id])
      if @feed.update_attributes(params[:feed])
        flash[:notice] = "feed was successfully updated"
        redirect_to(admin_feeds_url)
      else
        render(:action => "edit")
      end
    end
    
    def new
      @feed = Feed.new
    end
    
    def create
      feed = Feed.create(params[:feed])
      feed.save!
      redirect_to(admin_feeds_url)
    end
    
    def toggle_state
      # Change the active state of a feed
      f = Feed.find(params[:id])
      f.toggle! :active    
      redirect_to(admin_feeds_url)
    end
  
    def pull
      # Admin method that pulls manually pulls a feed. returns json
      # about the status of the pull
            
      return render(:text => "error no feed ids") unless params[:feed_id]
      
      opts = {}
      if params[:all]
        opts[:all] = true
      else
        opts[:from] = params[:from]
      end      
      
      feed_results = []
      params[:feed_id].each do |f|        
        feed = Feed.find(f)
        pg = AlertGenerator::AvantlinkFeedParser.new(feed)
        r = pg.download_feed(OPTIONS[:full_feed_location], opts)

        begin
          pg.process_product_feed(r) # Process the feed
          feed_results << "#{feed.name}: success</br>"
        rescue Exception => e
          feed_results << "#{feed.name}: #{e.message}</br>"
        end
        
      end
                        
      render(:text => feed_results.to_s)
    end
       
  end
end