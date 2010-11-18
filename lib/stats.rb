require 'openssl'
require 'csv'

module Stats
  
  def self.get_daily_average(table_name)
    # Simple function that returns a daily average of a table for a specific column
    sql = "SELECT AVG(r.c) FROM ( select count(*) AS c FROM #{table_name} GROUP BY DATE(created_at) ) AS r"
    result = ActiveRecord::Base.connection.execute(sql)
    return result.fetch_row()[0].to_i
  end
              
  def self.get_date_range_from_strings(options = {})
    
    # Default is today at 00:00:00 and 23:59:59
    sd = options[:start_date] ? Time.parse(options[:start_date]) : Time.zone.now.to_date
    ed = options[:end_date] ? Time.parse(options[:end_date]) : Time.zone.now.to_date
    
    sd = Time.local(sd.year, sd.month, sd.day, 0, 0, 0)
    ed = Time.local(ed.year, ed.month, ed.day, 23, 59, 59)

    # We can specify a start date offset instead of using today
    sd -= (3600 * 24 * options[:start_offset]) if options[:start_offset]
    
    return [sd, ed]
  end
        
  def self.get_data(data, dates)
    # Fill in blank dates with zeroes
    
    return_array = []
    
    dates.each do |d|      
      if data.has_key?(d.to_s)
        return_array << data[d.to_s]
      else
        return_array << 0
      end        
    end
    
    return return_array  
  end
  
  def self.get_avantlink_performance(start_date, end_date)
    # Get performance info from avantlink    
    # Merchant,Ad Impressions,Click Throughs,Sales,# of Sales,Commissions,Incentives,# of Adjustments,Conversion Rate,Average Sale Amount,Click Through Rate,eCPM

    s = start_date.strftime("%Y-%m-%d")
    e = end_date.strftime("%Y-%m-%d")
    affil_id = 10309
    auth_key = "bee5c678e8f840e368101741a0f67f55"
    
    # Open the url via ssh
    http = Net::HTTP.new('www.avantlink.com', 443)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    
    url = "/api.php?affiliate_id=#{affil_id}&auth_key=#{auth_key}&module=AffiliateReport&output=csv&report_id=1&date_begin=#{s}&date_end=#{e}"
    f = http.get(url)        
    clicks = 0
    sales = 0
    revenue = 0
                
    # Loop over each row. Ignore the first row    
    count = 0
    f.body.split("\r\n").each do |row|
      if count != 0
        data = CSV::parse_line(row)
        clicks += data[2].to_i
        # Add revenue after removing dollar signs
        revenue += data[5].delete("$").to_f
        sales += data[4].to_i
      end
      count += 1
    end
    
    return [clicks, sales, revenue]
  end
  
end