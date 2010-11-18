require 'text'

module VoteProcessing
  
  def self.get_email_root(email_address)
    # Take an email address, remove domain, and pull out non-[a-z] characters
    raise ArgumentError, "email address is not a string" unless email_address.is_a? String     
    e_array = email_address.split("@")
    raise Exception, "email address: #{email_address} is an invalid email address" unless e_array.length == 2
    return e_array[0].gsub(/[^a-z]/i,'').downcase
  end
  
  def self.get_email_distance(s1, s2)
    # Get the distance between two strings
    r1 = get_email_root(s1)
    r2 = get_email_root(s2)
    return Text::Levenshtein.distance(r1, r2)
  end
  
end