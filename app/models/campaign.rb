class Campaign < ActiveRecord::Base
  has_many :users
  
  validates_presence_of :name, :public_id
  validates_uniqueness_of :public_id  
end