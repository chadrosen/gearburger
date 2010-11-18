class Click < ActiveRecord::Base
    
  belongs_to :user
  has_many :sales
  
  # These are optional
  belongs_to :user_product_email
  belongs_to :product
  belongs_to :products_user

  validates_inclusion_of :click_type, :in => %w( product_email_link product_link)
    
  def self.track!(user, click_type, options = {})        
    Click.create!(:click_type => click_type, :version => options[:version] || 1, :source => options[:source], 
      :user => user, :user_product_email => options[:user_product_email], :product => options[:product],
      :products_user => options[:product_user])
  end
  
  def self.click_count(click_type, start_date, end_date)
    Click.count(:conditions => ["click_type = ? AND created_at BETWEEN ? AND ?", click_type, start_date.getutc, end_date.getutc])    
  end
    
end
