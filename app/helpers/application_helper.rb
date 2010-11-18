# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def get_price_percentage(retail, sale)
    return Product.get_price_percentage(retail, sale)
  end

  def get_price_percentage_string(retail, sale)
    # Parse the data into floats and then return the result
    retail = retail.strip.gsub("$", "")
    sale = sale.strip.gsub("$", "")
    return get_price_percentage(retail, sale)
  end

  def per_off_less_than_percent(retail, sale, per_off)
    sale.nil? ? false : ((sale / retail) * 100) < per_off    
  end
  
  def format_date(date)
    return date.nil? ? "" : date.strftime("%m/%d/%Y %I:%M:%S %p")
  end
  
  def redirector_url(upe, options = {})
  
    url = nil
    if options[:action] and options[:controller]
      url = url_for(
        :controller => options[:controller] , 
        :action => options[:action], 
        :only_path => false)
    end
    
    return url_for(
      :controller => "products", 
      :action => "product_email_redirector", 
      :only_path => false,  
    	:upe => upe.id,
    	:url => url,
    	:source => options[:source],
    	:p => options[:p],
    	:pu => options[:pu]
    )  
    
  end 
  
end
