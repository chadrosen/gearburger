include AbingoSugar
require 'SmtpApiHeader'

# Category stuff for sendgrid
CategoryAdmin = "admin"
CategoryProductEmail = "product email"
CategoryTest = "test"

class ProductNotificationMailer < BaseMailer
              
  def product_price_change(user, category_rows, options = {})
    # Deliver the product email. Takes an optional user object and
    # generates tracking objects
        
    # User is optional so that we can send these to users not actually in the system... for testing
            
    upe = UserProductEmail.create!(:user => user, :sent_at => Time.now)
  
    # Keep track of each of the products that we send out
    product_count = 0
    category_rows.each do |cr|
      category = cr[0]
      product_rows = cr[1]
      product_rows.each do |pr|
        pr.each_with_index do |p,i|
          pu = ProductsUser.new(:user_product_email => upe, :user => user, :product => p)
          pu.save!
          pr[i] = pu
          product_count += 1
        end
      end
    end
      
    # Generate some grouped data for HTML emails
    @category_rows = category_rows
                                                           
    deals = product_count == 1 ? "Deal" : "Deals"
    @today = Time.zone.today
    @upe = upe
    @user = user
    
    # sendgrid
    headers = get_sendgrid_header(CategoryProductEmail)    
    headers["Precedence"] = "bulk"
    
    mail(:to => user.email, :subject => "Today's Gear Burger Sale Alert") do |format|
      format.text { render "product_price_change.text" }
      format.html { render "product_price_change.html" }
    end

  end
  
  def product_generator_error(feed, exception)
    # There was an error in the product generation
        
    headers = get_sendgrid_header(CategoryAdmin)
    
    @env = Rails.env.to_s
    @exception = exception
    @feed = feed
    
    mail(:to => OPTIONS[:internal_error_to], 
      :subject => "Product generator error in #{Rails.env.to_s}: #{exception.message}")
  end
  
  def product_generator_results(product_generation_summaries)
    # Send us the results of the product generation
    
    headers = get_sendgrid_header(CategoryAdmin)
        
    @pgs = product_generation_summaries
    
    mail(:to => OPTIONS[:internal_email_to], 
      :subject => "Product generation results for #{Time.zone.today} in #{Rails.env.to_s}")
  end
  
  def product_email_results(sent, created, errors)
    # Send us the results of the product match emails..
    
    headers = get_sendgrid_header(CategoryAdmin)
    
    @sent = sent
    @created = created
    @errors = errors
    
    mail(:to => OPTIONS[:internal_email_to],
      :subject => "#{Time.zone.today} #{Rails.env.to_s} Queued: #{created} Sent: #{sent} Errors: #{errors.length}")
  end
  
  def simple_test(email)
    # Send us the results of the product match emails..
    
    headers = get_sendgrid_header(CategoryTest)    
    
    Abingo.identity = rand(10 ** 10).to_i.to_s
      
    subject = ""  
    ab_test("call_to_action", %w{foo1 foo2 foo3 foo4 foo5}) { subject = button }
    
    mail(:to => email, :subject => "subject")
  end
  
  private

  def get_sendgrid_header(category, params = {})
    
    to = params[:to] || OPTIONS[:internal_error_to]
    
    headers = {}
    hdr = SmtpApiHeader.new()
    hdr.addTo(to)
    hdr.setCategory(category)
    headers["X-SMTPAPI"] = hdr.asJSON()
    return headers
  end
      
end