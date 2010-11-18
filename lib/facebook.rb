module AuthenticatedSystem
  
  def get_facebook_cookie

    # Attempt to get fb cookie
    id = "fbs_#{OPTIONS[:facebook_app_id]}"    
    cookie = request.cookies[id]    
    return unless cookie
          
    # The cookie seems to have double-quotes in it
    cookie.delete!('"')
          
    # Split the cookie into a hash
    params = CGI.parse(cookie)
        
    puts params["access_token"]
    
    return params
     
     # TODO: fix this later...   
    #return valid_payload?(params) ? params : nil  
  end
  
  def valid_payload?(params)
    # Make sure the data returned from fb is valid
    
    # TODO: fix this later..
    return true
    
    # Validate the payload by hashing everything but the sig and then comparing to the sig
    payload = ""
    params.each { |k,v| payload += "#{k}=#{v}" if k != "sig" }
    digest = Digest::MD5.hexdigest("#{payload}#{OPTIONS[:facebook_secret_key]}")
    return digest == params["sig"]
  end
  
  # Attempt to login a user from facebook
  def login_from_facebook
    fb_cookie = get_facebook_cookie
    return unless fb_cookie and fb_cookie["uid"]

    #uid : 507527287
    #sig : ddf9dffcd85fcc41dbe4257b5eee922b
    #base_domain : gear.com
    #secret : fSoxbS_tGGF0oP2c9_SUbw__
    #access_token : 225955489319|2.KBSGTAnBP5tSEIxJBXcWfA__.3600.1278799200-507527287|d5zULU1zLZFguUUcsqVU0-C-tOM.
    #session_key : 2.KBSGTAnBP5tSEIxJBXcWfA__.3600.1278799200-507527287
    #expires : 1278799200

    user = User.find_by_fb_user_id(fb_cookie["uid"])

    # cant find the user in the db but they have a fb session..
    return unless user
    
    # Add fb user to the user object and set the current user
    self.current_user = user      
  end
  
  def logout_fb
    # Logout of fb. No 100% sure this works. Also, delete session from javascript in the ui
    fb_id = "fbs_#{OPTIONS[:facebook_app_id]}"      
    request.cookies.delete fb_id       
  end
  
end