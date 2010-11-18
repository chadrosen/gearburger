class UserInvite < ActiveRecord::Base
  belongs_to :invited_by, :class_name => "User", :foreign_key => "user_id"
  has_one :registered_user, :primary_key => "email_address", :foreign_key => "email", :class_name => "User" 
  
  validates_inclusion_of :state, :in => %w( pending sent error )
  
end
