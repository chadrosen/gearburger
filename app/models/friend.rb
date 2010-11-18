class Friend < ActiveRecord::Base
  validates_presence_of :name, :blog_url, :image_url, :description
  validates_length_of :name, :minimum => 3
  validates_length_of :blog_url, :minimum => 7
  validates_length_of :image_url, :minimum => 7
  validates_length_of :description, :minimum => 3    
end
