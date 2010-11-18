class Contest < ActiveRecord::Base

  has_many :captions  
  validates_presence_of :image_url, :start_time, :end_time, :prize_url
  validates_presence_of :prize_name, :prize_price
end
