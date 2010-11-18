module UsersHelper

  def get_grouped_data(item_array, options = {})
    
    group_count = options[:group_count] || 3
    fill_with = options[:fill_with] || nil
        
    return item_array.in_groups_of(group_count, fill_with).collect { |g| g }
  end
  
  def get_redirector_url(obj)
    # Return the appropriate redirector url for an obj type
    obj.class == Product ? product_redirector_url(obj, :source => "home_page") : alert_url(obj.alert_id, :source => "home_page")
  end
  
  def get_time_ago(obj)
    # Return appropriate time ago depending on product type..
    t = (obj.class == Product and obj.price_changed_at) ? obj.price_changed_at : obj.created_at
    time_ago_in_words(t)
  end
  
  def get_break_options
    return User::BreakOptions.collect { |v| ["#{v} from now", v] }
  end
    
  def get_discount_preferences
    User::DiscountOptions.collect { |d| [ d, User::DiscountValues[d] ] }
  end
    
end