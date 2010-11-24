module Sendgrid
  
  # Use this module to talk to sendgrid
  
  SENDGRID_URL = "https://sendgrid.com/api"
  
  class ClearEmailJob < Struct.new
    # Uses delayed job plugin to initialize a sales processor and download the report
  
    def perform
      # Clean out users who have invalid info from sendgrid
      cie = Sendgrid::ClearInvalidEmails.new
      cie.clear_emails
    end    
   end
  
  class SendgridAPI
    
    def initialize(api_user, api_key)
      @api_user = api_user
      @api_key = api_key
    end
    
    def call_sendgrid(method, action, options = {})
    
      result_type = options[:result_type] || "json" # json or xml
      params = options[:params] || {} # Optional set of params added to url
      
      # Compose url
      url = "#{SENDGRID_URL}/#{method}.#{action}.#{result_type}?api_user=#{@api_user}&api_key=#{@api_key}&#{params.to_query}"
      
      Rails.logger.debug "Sendgrid URL #{url}"
      
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      return ActiveSupport::JSON.decode(response.body)    
    end
    
  end
  
  class ClearInvalidEmails
    
    def initialize(options = {})
      
      # TODO: Use username and password
      # TODO: Use start date and end date
      
      @api = SendgridAPI.new(OPTIONS[:sendgrid_username], OPTIONS[:sendgrid_password])
    end
    
    def clear_emails
      
      # http://sendgrid.com/documentation/ApiWeb

      # http://sendgrid.com/documentation/ApiWebBounces
      # https://sendgrid.com/api/bounces.get.json?api_user=youremail@domain.com&api_key=secureSecret&date=1
      # [{"email":"email1@domain.com","status":"5.1.1","reason":"host [127.0.0.1] said: 550 5.1.1 unknown or illegal user: email1@domain.com","created":"2009-06-01 19:41:39"}]
      
      ["bounces", "invalidemails", "spamreports"].each do |action|
      
        Rails.logger.info "Get #{action} messages from sendgrid"
      
        # Get error messages from sendgrid
        messages = @api.call_sendgrid(action, "get")

        Rails.logger.info "#{messages.length} #{action} messages found"

        messages.each do |message|
          
          # Grab the invalid email
          email = message["email"]
          
          # Find result in db
          u = User.find_by_email(email)
          
          if u.nil?
            Rails.logger.info "Could not find user in db with email #{email}"
            next
          end
          
          Rails.logger.info "Found user #{u.email}. Deactivate them with reason #{action}"

          # Deactivate the user and set the reason
          u.deactivation_reason = action
          u.deactivate!
          
          # Delete the message in sendgrid
          Rails.logger.info "Delete sendgrid record #{action} for user #{email}"
          result = @api.call_sendgrid(action, "delete", :params => {"email" => email})
          
          message = result["error"] ? result["error"]["message"] : result["message"]
          Rails.logger.info "Delete result #{action} for user #{email}: #{message}"          
        end

      end


      # http://sendgrid.com/documentation/ApiWebMailInvalidEmails
      # [{"email":"isaac@hotmail.comm","reason":"Mail domain mentioned in email address is unknown","created":"2009-06-01 19:41:39"}]

      # http://sendgrid.com/documentation/ApiWebMailSpamReports
      # [{"email":"email1@domain.com","created":"2009-06-01 19:41:39}]
     
      
      
    end
    
  end
  
  
end