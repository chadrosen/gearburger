require 'stats'

module Admin

  class StatInfo
    
    include ActionView::Helpers::NumberHelper
    attr_accessor :name, :sent, :users_sent, :views, :view_rate, :clicks, :rate, :revenue, :ecpc, :stat_id
    attr_accessor :rate_formatted, :revenue_formatted, :ecpc_formatted
    def initialize(stat_id, name, options = {})
      @stat_id = stat_id
      @name = name
      @sent = options[:sent] || 0
      @users_sent = options[:users_sent] || 0
      @views = options[:views] || 0
      @clicks = options[:clicks] || 0
      @revenue = options[:revenue] || 0.0      
      @rate = @views == 0 ? 0.0 : @clicks.to_f / @views.to_f * 100.0
      @ecpc = @revenue == 0 ? 0.0 : @revenue.to_f / @clicks.to_f
      @view_rate = @sent == 0 ? 0.0 : @views.to_f / @sent.to_f * 100.0
      
      # Format these here so I don't have to do it in javascript
      @view_rate_formatted = number_to_percentage(@view_rate, :precision => 2)
      @rate_formatted = number_to_percentage(@rate, :precision => 2) 
      @revenue_formatted = number_to_currency(@revenue)
      @ecpc_formatted = number_to_currency(@ecpc)
    end
    
    def to_hash
      return {
        :stat_id => @stat_id,
        :name => @name,
        :sent => @sent,
        :users_sent => @users_sent,
        :views => @views,
        :clicks => @clicks,
        :revenue => @revenue.to_f,
        :view_rate => @view_rate,
        :rate => @rate,
        :ecpc => @ecpc.to_f,
        :revenue_formatted => @revenue_formatted,
        :rate_formatted => @rate_formatted,
        :ecpc_formatted => @ecpc_formatted,
        :view_rate_formatted => @view_rate_formatted
      }
    end
  end

  class StatsController < AdminController
    
    include ActionView::Helpers::NumberHelper # Include number helpers so I can format numbers
            
    def summary
      # A set of summary stats

      @start_date, @end_date = Stats::get_date_range_from_strings(:start_date => params[:start_date], :end_date => params[:end_date])                  
      @indicators = [
        StatInfo.new("product_email", 
          "Product email", 
          :sent => UserProductEmail.count(:conditions => ["sent_at BETWEEN ? AND ?", @start_date.getutc, @end_date.getutc]),
          :users_sent => UserProductEmail.count(:conditions => ["sent_at BETWEEN ? AND ?", @start_date.getutc, @end_date.getutc], :group => 'user_id').length,
          :views => UserProductEmail.count(:conditions => ["viewed = ? AND sent_at BETWEEN ? AND ?", true, @start_date.getutc, @end_date.getutc]),
          :clicks => UserProductEmail.count(:conditions => ["clicked = ? AND sent_at BETWEEN ? AND ?", true, @start_date.getutc, @end_date.getutc]),
          :revenue => Sale.get_click_commissions(:product_email_link, @start_date, @end_date)
        ),
        StatInfo.new("product_links", "Product links") # Placeholder. Filled out in google stats below..
      ]
                                
      # User state changes
      @total = User.count(:conditions => ["state = 'active'"])
      @active = User.count(:conditions => ["state = 'active' AND created_at BETWEEN ? AND ?", @start_date.getutc, @end_date.getutc])
      @pending = User.count(:conditions => ["state = 'pending' AND created_at BETWEEN ? AND ?", @start_date.getutc, @end_date.getutc])
      @deleted = User.count(:conditions => ["state = 'inactive' AND deleted_at BETWEEN ? AND ?", @start_date.getutc, @end_date.getutc])
      
      # Get our totals (not avantlink) so we can make sure things are lining up
      @clicks = Click.count(:conditions => ["created_at BETWEEN ? AND ?", @start_date.getutc, @end_date.getutc])
      @sales = Sale.count(:conditions => ["sale_type = ? AND transaction_time BETWEEN ? AND ?", :sale, @start_date.getutc, @end_date.getutc])
      @returns = Sale.count(:conditions => ["sale_type = ? AND transaction_time BETWEEN ? AND ?", :adjustment, @start_date.getutc, @end_date.getutc])
      @revenue = Sale.sum(:total_commission, :conditions => ["transaction_time BETWEEN ? AND ?", @start_date.getutc, @end_date.getutc])
      
      @users = User.where(:created_at => (@start_date.getutc...@end_date.getutc) ).order("updated_at DESC").all      
    end
    
    def avantlink_stats
      # Stats that require webservice calls.. Slower and therefore meant to be ajaxed in..
      start_date, end_date = Stats::get_date_range_from_strings(:start_date => params[:start_date], :end_date => params[:end_date])

      # Avantlink info
      clicks, sales, revenue = Stats.get_avantlink_performance(start_date.to_date, end_date.to_date)
      render :json => {:clicks => clicks, :sales => sales, :revenue => number_to_currency(revenue)}
    end
    
    def google_stats
      # Stats that require webservice calls.. Slower and therefore meant to be ajaxed in..
      #start_date, end_date = Stats::get_date_range_from_strings(:start_date => params[:start_date], :end_date => params[:end_date])
      
      #profile = Rugalytics.default_profile
      #pageviews = profile.pageviews :from => start_date.to_date.to_s, :to => end_date.to_date.to_s
      #visits = profile.visits :from => start_date.to_date.to_s, :to => end_date.to_date.to_s   
      
      # Data for the product links. Requires google analytics info for views
      #report = profile.top_content_detail_report(:url => "/sale_spot", :from => start_date.to_date.to_s, :to => end_date.to_date.to_s)
      #sale_spot_views = report.pageviews_total
      
      #si = StatInfo.new("product_links", 
      #  "Product links",
      #  :views => sale_spot_views.to_i,
      #  :clicks => Click.click_count(:product_link, start_date, end_date),
      #  :revenue => Sale.get_click_commissions(:product_link, start_date, end_date)
      #)
               
      #render :json => {:pageviews => pageviews, :visits => visits, 
      #  :ss_views => sale_spot_views, :ss_clicks => si.clicks, :ss_revenue => si.revenue_formatted, 
      #  :ss_rate => si.rate_formatted, :ss_rpc => si.ecpc_formatted}        
    end
        
    def monthly_users
      
      q = Proc.new { |date_at_column|
        # Summarize a "date_at" column on the users table by month and year
        sql = "
          SELECT 
            YEAR(#{date_at_column}) as year, 
            MONTH(#{date_at_column}) as month,
            count(*) as count 
          FROM 
            users
          WHERE
            YEAR(#{date_at_column}) IS NOT NULL
            AND MONTH(#{date_at_column}) IS NOT NULL
          GROUP BY 
            year, 
            month
          ORDER BY
            year DESC,
            month DESC
        "    
        ActiveRecord::Base.connection.select_all(sql)
      }

      # TODO: not the best.. but fine for now
      created = q.call("created_at")
      deleted = q.call("deleted_at")

      @results = []
      created.each_with_index do |c, i|
                
        del = deleted[i].nil? ? 0 : deleted[i]['count'].to_i
                
        r = {
          :date => "#{c['month']}/#{c['year']}",
          :created => c['count'].to_i,
          :deleted => del,
          :net => c['count'].to_i - del
        }
        
        @results << r        
      end
    end
      
    def stats_over_time
      # Get user summary stats over time
      @start_date, @end_date = Stats::get_date_range_from_strings(:start_date => params[:start_date], 
        :end_date => params[:end_date])
      @group_by = (@start_date.getutc.to_date...@end_date.getutc.to_date).to_a.reverse
      @results = get_stats_by_group(:date, @group_by, @start_date, @end_date)
    end
    
    def campaign_stats
      # Get user stats aggregated by campaign
      @start_date, @end_date = Stats::get_date_range_from_strings(:start_date => params[:start_date], 
        :end_date => params[:end_date])
      @group_by = Campaign.find_all_by_active(true, :order => "id ASC").collect { |c| c.id }
      @campaign_dict = {}
      Campaign.find_all_by_id(@group_by).each { |c| @campaign_dict[c.id] = c }
      @results = get_stats_by_group(:campaign_id, @group_by, @start_date, @end_date)      
    end
    
    def product_generation
      
      date = Time.zone.today
      
      @start_date, @end_date = Stats::get_date_range_from_strings(:start_date => params[:start_date], 
        :end_date => params[:end_date], :start_offset => 3)            
        
      q = ProductGenerationSummary.where(["created_at BETWEEN ? AND ?", @start_date.getutc, @end_date.getutc])
      @results = q.order("created_at DESC").includes(:feed).all
    end
    
    def user_behavior
      @start_date, @end_date = Stats::get_date_range_from_strings(:start_date => params[:start_date], 
        :end_date => params[:end_date])
              
      @options = [["Most Views", "views"], ["Most Clicks", "clicks"], ["Most Sales", "sales"], 
        ["Most Revenue", "revenue"]]
      @count_limit = params[:count_limit] || 0
      
      # Base for everything
      conditions = { :created_at => (@start_date...@end_date) }
      having = ["count_all > ?", @count_limit]
      @limit = params[:limit] || 50
      @stat = params[:stat]
      
      if @stat == "clicks"
        @r = Click.count(:group => :user, :joins => [:user], 
          :conditions => conditions, :order => "count_all DESC", :having => having,
          :limit => @limit) 
      
      elsif @stat == "sales"
        @r = Sale.count(:group => :user, :joins => [:user], 
          :conditions => conditions, :order => "count_all DESC", :having => having,
          :limit => @limit)
      
      elsif @stat == "revenue"
        @r = Sale.sum(:total_commission, :group => :user, :joins => [:user], 
          :conditions => conditions, :order => "sum_total_commission DESC", 
          :having => ["sum_total_commission > ?", @count_limit], :limit => @limit)
          
      else
        # Default is views
        conditions = { :viewed_at => (@start_date...@end_date), :viewed => true }
        @r = UserProductEmail.count(:group => :user, :joins => [:user], 
          :conditions => conditions, :order => "count_all DESC", :having => having,
          :limit => @limit)
      end
      
      user_ids = @r.collect { |user, count| user.id }
      user_ids.uniq!
      @stats = get_stats_for_users(user_ids, @start_date, @end_date)
    end
    
    def click_stats
      # Get information about products that were clicked
      
      @start_date, @end_date = Stats::get_date_range_from_strings(:start_date => params[:start_date], 
        :end_date => params[:end_date])
      
      @clicks = Click.count(:conditions => ["clicks.created_at between ? and ? and product_id is not null", 
        @start_date, @end_date])
              
      @products.where(["clicks.created_at between ? and ?", @start_date, @end_date]).joins(:clicks).all
      
      @products.uniq!
      
      total_retail = 0.0
      total_sale = 0.0
      categories = Set.new
      brands = Set.new
            
      @products.each do |p|
        total_retail += p.retail_price
        total_sale += p.sale_price
        categories << p.category
        brands << p.brand
      end
      
      @avg_sale = total_sale / @products.length
      @avg_retail = total_retail / @products.length
      @avg_discount = (@avg_retail - @avg_sale) / @avg_retail      
      
      @cats = categories.collect { |c| c.name if c }
      @brs = brands.collect { |b| b.name }
      
    end
  
    protected
    
    def get_stats_for_users(user_ids, start_date, end_date)
      # Get activity summary stats for a group of user_ids
      
      results = {}
      
      conditions = { :created_at => (start_date...end_date), :user_id => user_ids }
            
      # Queries
      clicks = Click.count(:group => :user_id, :conditions => conditions) 
      sales = Sale.count(:group => :user_id, :conditions => conditions)
      revenue = Sale.sum(:total_commission, :group => :user_id, :conditions => conditions)

      # Special conditions for views
      conditions = { :viewed_at => (start_date...end_date), :viewed => true, :user_id => user_ids }
      views = UserProductEmail.count(:group => :user_id, :conditions => conditions)
      
      user_ids.each do |u_id|
      
        results[u_id] = {
          :views => views[u_id] || 0,
          :clicks => clicks[u_id] || 0,
          :sales => sales[u_id] || 0,
          :revenue => revenue[u_id] || 0.0
        }
      end
      
      return results
      
    end

    def get_stats_by_group(group, group_by, start_date, end_date)

      time_range = (start_date.getutc...end_date.getutc)
      
      if group == :date
        g = {        
          :sent => "DATE(sent_at)",
          :created => "DATE(created_at)",
          :deleted => "DATE(deleted_at)",
          :upe => "DATE(user_product_emails.created_at)",
          :tx => "DATE(transaction_time)"
        }
      else
        g = {        
          :sent => "users.campaign_id",
          :created => "users.campaign_id",
          :deleted => "users.campaign_id",
          :upe => "users.campaign_id",
          :tx => "users.campaign_id"
        }
      end

      # sent at queries
      es = UserProductEmail.count(:group => g[:sent], :include => [:user], :conditions => {:sent_at => time_range})
      v = UserProductEmail.count(:group => g[:sent], :include => [:user], :conditions => {:viewed => true, :sent_at => time_range})

      # created_at queries
      cus = User.count(:group => g[:created], :conditions => {:created_at => time_range})
      
      # Deleted_at
      dus = User.count(:group => g[:deleted], :conditions => {:deleted_at => time_range})        
      
      # UPE has it's own thing
      c = UserProductEmail.count(:group => g[:upe], :include => [:user], :conditions => {:clicked => true, :sent_at => time_range })

      # tx time queries
      s = Sale.count(:group => g[:tx], :include => [:user], :conditions => {:sale_type => :sale, :transaction_time => time_range })
      ret = Sale.count(:group => g[:tx], :include => [:user], :conditions => {:sale_type => :adjustment, :transaction_time => time_range })
      rev = Sale.sum(:total_commission, :group => g[:tx], :include => [:user], :conditions => {:transaction_time => time_range })

      # Put the data in hashes so we can look it up by group
      emails_sent_d = Hash[es]
      email_views_d = Hash[v]
      email_clicks_d = Hash[c]
      sales_d = Hash[s]
      returns_d = Hash[ret]
      revenue_d = Hash[rev]
      created_users_d = Hash[cus]
      inactive_users_d = Hash[dus]
      
      results = {}
      group_by.each do |d|

        # Set the k to a string unless it's nill
        k = d.to_s unless d.nil?
        
        sent = emails_sent_d[k] || 0
        views = email_views_d[k] || 0
        clicks = email_clicks_d[k] || 0 
        sales = sales_d[k] || 0
        returns = returns_d[k] || 0
        revenue = revenue_d[k] || 0.0
        
        # Weird. For some reason the keys are ints no strings for these values in campaign stats... lame
        if group == :date
          created_users = created_users_d[k] || 0
          inactive_users = inactive_users_d[k] || 0
        else
          created_users = created_users_d[k.to_i] || 0
          inactive_users = inactive_users_d[k.to_i] || 0
        end
          
        # rates
        view_rate = sent == 0 ? 0.0 : views.to_f / sent.to_f * 100.0        
        click_rate = views == 0 ? 0.0 : clicks.to_f / views.to_f * 100.0
        rpc = revenue == 0.0 ? 0.0 : revenue.to_f / clicks.to_f

        # dont use nil as a key use "null"
        k = d.nil? ? "null" : d.to_s

        results[k] = { 
          :emails_sent => sent,
          :email_views => views,
          :clicks => clicks,
          :sales => sales,
          :returns => returns, 
          :revenue => revenue,
          :created_users => created_users,
          :inactive_users => inactive_users,
          :view_rate => view_rate,
          :click_rate => click_rate,
          :rpc => rpc
        }        
      end

      return results
    end
        
  end
  
  
end