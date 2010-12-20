class ProductsController < ApplicationController
        
  # This is the only redirector that requires a login
  before_filter :protect_login, :only => [:product_redirector]  
  
  skip_filter :set_layout_data
      
  def product_price_email_pixel
    # Comes from a product price update
    # Keep track that a product email was viewed
    return render(:nothing => true) unless params[:user_product_email_id]
    
    begin
      upe = UserProductEmail.find(params[:user_product_email_id])
      upe.update_attributes!(:viewed => true, :viewed_at => Time.now)
    rescue
      return render(:nothing => true)
    end
    
    return render(:nothing => true)
  end
            
  def product_email_redirector
      
    # Upe is always required
    return redirect_to(root_url) unless params[:upe]

    # One of these two sets of parameters are required paramaters
    if !(params[:url] and params[:source]) and !params[:p]
      return redirect_to(root_url)
    end
    
    begin
      # The UPE must be valid
      upe = UserProductEmail.find(params[:upe]).include(:product)
      upe.update_attributes!(:clicked => true, :clicked_at => Time.now)           

      # Normal redirection case. Just redirect to a url
      decorate_and_redirect(upe.user, upe.product.buy_url, "product_email_link", :source => params[:source], 
        :user_product_email => upe)
    rescue
      return redirect_to(root_url)
    end        
  end
  
  def product_redirector
    # Redirect to the buy url of a product and append some custom params for tracking
    
    begin
      p = Product.find(params[:product_id])
      decorate_and_redirect(current_user, p.buy_url, "product_link")
    rescue ActiveRecord::RecordNotFound => rnf
      redirect_to(root_url)
    end
    
  end
              
private

  def decorate_and_redirect(user, url, click_type, options = {})
        
    # Track the click
    c = Click.track!(user, click_type, options)
    
    # Add url question mark if it isn't there, otherwise add &..
    url = url.include?("?") ? "#{url}&ctc=#{c.id}" : "#{url}?ctc=#{c.id}"    
    redirect_to(url)
  end
  
end