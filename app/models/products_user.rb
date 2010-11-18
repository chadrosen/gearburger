class ProductsUser < ActiveRecord::Base
  # Keeps track of the different products that have been sent to a user
  # in each email
  belongs_to :user
  belongs_to :product
  belongs_to :user_product_email, :counter_cache => true
  
  validates_presence_of :user_id, :product_id, :user_product_email_id
end
