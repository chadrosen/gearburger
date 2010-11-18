class Caption < ActiveRecord::Base

  has_many :votes
  belongs_to :user
  belongs_to :contest, :counter_cache => true
  
  validates_length_of :description, :maximum => 120
  validates_presence_of :description
end
