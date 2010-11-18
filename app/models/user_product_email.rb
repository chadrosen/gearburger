class UserProductEmail < ActiveRecord::Base
  belongs_to :user
  
   # A single email is made up of many products_user which map to products
  has_many :products_users
  has_many :products, :through => :products_users
    
end
