class Sale < ActiveRecord::Base
  belongs_to :click
  belongs_to :user
  
  TYPE_SALE = "sale"
  TYPE_ADJUSTMENT = "adjustment"
  
  validates_inclusion_of :sale_type, :in => [TYPE_SALE, TYPE_ADJUSTMENT]
  
  def self.get_click_commissions(click_type, start_date, end_date)
    Sale.sum(:total_commission, :include => [:click], :conditions => ["transaction_time BETWEEN ? AND ? AND clicks.click_type = ?", 
      start_date.getutc, end_date.getutc, click_type])
  end
end
