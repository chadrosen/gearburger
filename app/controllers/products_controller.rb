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
    if !(params[:url] and params[:source]) and !(params[:p] and params[:pu])
      return redirect_to(root_url)
    end
    
    begin
      # The UPE must be valid
      upe = UserProductEmail.find(params[:upe])
      upe.update_attributes!(:clicked => true, :clicked_at => Time.now)           
    rescue
      return redirect_to(root_url)
    end
          
    # Normal redirection case. Just redirect to a url
    if params[:url] and params[:source]
      return decorate_and_redirect(upe.user, params[:url], "product_email_link", 
        :source => params[:source], :user_product_email => upe)
    end
                
    begin
      
      # Run everything in a tx
      UserProductEmail.transaction do
      
        # Get the data
        p = Product.find(params[:p])
        pu = ProductsUser.find(params[:pu])
        
        # Make sure everything is connected...
        if p.id != pu.product_id or pu.user_product_email_id != upe.id
          return redirect_to(root_url)
        end
        
        # Update tracking on objects
        pu.update_attributes!(:clicked => true, :clicked_at => Time.now)
        
        # Decorate url and redirect
        decorate_and_redirect(upe.user, p.buy_url, "product_email_link", 
          :user_product_email => upe, :product => p, :product_user => pu)
      end
      
    rescue Exception => e
      redirect_to(root_url)
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
    # Pass along the abingo cookie as the identifier, for now
    c = Click.track!(user, click_type, options)
    
    # Add url question mark if it isn't there, otherwise add &..
    url = url.include?("?") ? "#{url}&ctc=#{c.id}" : "#{url}?ctc=#{c.id}"    
    redirect_to(url)
  end
  
end