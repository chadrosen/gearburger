#!/usr/bin/env ruby 
require 'rubygems'
require 'open-uri'
require 'csv'
require 'bigdecimal'
require 'bigdecimal/util'

module AlertGenerator
    
  class SalesProcessor
    def initialize(options = {})
      @url_params = {
        :affiliate_id => options[:affiliate_id] || 10309,
        :module => options[:module] || "AffiliateReport",
        :output => options[:output] || "csv",
        :report_id => options[:report_id] || 8,
        :auth_key => options[:auth_key] || "bee5c678e8f840e368101741a0f67f55"        
      }    
      @url = options[:url] || "https://www.avantlink.com/api.php"
    end
        
    def download_report(start_date, end_date, options = {})
      @url_params[:date_begin] = start_date
      @url_params[:date_end] = end_date
      url = "#{@url}?#{@url_params.to_query}"
      
      puts url
                
      f = open(url)
      r = f.readlines
      f.close      
      return r  
    end
    
    def start(options = {})
      
      # Date processing crap
      start_date = options[:start_date] || Date.today
      end_date = options[:end_date] || Date.today
            
      sd = start_date.strftime("%Y-%m-%d 00:00:00")
      ed = end_date.strftime("%Y-%m-%d 23:59:59")
            
      report = download_report(sd, ed)
            
      report.each_index do |i|
        next if i == 0
        row = CSV.parse_line(report[i])
        process_row(row)
      end      
    
    end
        
    def process_row(row)
      
      # -- Report Columns
      # 0 Merchant 
      # 1 Website
      # 2 Tool Name
      # 3 Campaign/Product Link
      # 4 Custom Tracking Code
      # 5 Order Id
      # 6 Transaction Amount
      # 7 Base Commission
      # 8 Incentive Commission
      # 9 Total Commission
      # 10 Transaction Type
      # 11 Transaction Date
      # 12 Last Click Through,
      # 13 AvantLink Transaction Id
      # 14 Merchant Id
      tx_id = row[13]
      merchant_id = row[14]
      ctc = row[4].strip
      
      # Note: The new active record has issues using the CSV column.. Make sure to cast to int
      sale = Sale.find_or_initialize_by_transaction_id_and_merchant_id(tx_id.to_s, merchant_id.to_s)
      
      sale.merchant_name = row[0]
      sale.product_name = row[3]
      
      # Go ahead and set the ctc on the click. It may evaluate to invalid or 0
      sale.click_id = ctc
      sale.custom_tracking_code = ctc.empty? ? nil : ctc # Keep track of the original code

      # look for the user of the click
      c = Click.find_by_id(sale.click_id)
      sale.user_id = c.user_id if c && c.user_id
      
      sale.order_id = row[5]
      sale.transaction_amount = get_currency_from_string(row[6])
      sale.total_commission = get_currency_from_string(row[9])
      
      # Negative sales are adjustments not sales..
      # TODO: Do I want to key off the transaction_id instead of using negative?
      sale.sale_type = Sale::TYPE_ADJUSTMENT if sale.transaction_amount < 0
              
      # Sales for avantlink are recorded in mountain time..
      Time.zone = "Mountain Time (US & Canada)"
      sale.transaction_time = Time.zone.parse("#{row[11]}") if row[11]
      sale.last_click_through = Time.zone.parse("#{row[12]}") if row[12]
      sale.save!
    end
    
    def get_currency_from_string(str)
      str.delete!("$") # remove dollar sign..
      negative = str.index("(") == 0 ? true : false# Is it negative?
      str.delete!("(")
      str.delete!(")")
      c = str.to_d
      c *= -1 if negative
      return c
    end
    
  end
  
end