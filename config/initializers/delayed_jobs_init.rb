# There appears to be an issue un-marshalling ActiveRecord yaml objects.
# I found this link that gives a work around.
# http://groups.google.com/group/boston-rubygroup/browse_thread/thread/c9c49a1138723b95
YAML.add_domain_type("ActiveRecord,2008", "") do |type, val| 
  klass = type.split(':').last.constantize 
  YAML.object_maker(klass, val) 
end 

class ActiveRecord::Base 
  def to_yaml_type 
    "!ActiveRecord,2008/#{self.class}" 
  end 
end 

class ActiveRecord::Base 
  def to_yaml_properties 
    ['@attributes'] 
  end 
end
