require 'digest/md5'

module UserIdentity
  
  class IdentityTools
    
    def initialize()
    end
    
    def IdentityTools.get_identity_hash(ip_address, user_agent)
      # Hash the user agent and ip address to create a "semi" unique id for the click
      hs = ""
      hs << user_agent if user_agent
      hs << ip_address if ip_address
      Digest::MD5.hexdigest("#{hs}") unless hs.empty?
    end
    
  end
  
end