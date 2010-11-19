class Department < ActiveRecord::Base
  # A user can choose to monitor different sex params
  has_many :departments_users
  has_many :users, :through => :departments_users

  has_many :products
  
  validates_presence_of :name, :value
  validates_inclusion_of :active, :in => [true, false]
  validates_uniqueness_of :name, :value

  def self.get_value(product_name, feed_category, feed_subcategory, feed_product_group)
    text = "#{product_name} #{feed_category} #{feed_subcategory} #{feed_product_group}"

    # Check for kids
    regex = /\b(kid|boy|girl|youth|infant|toddler|junior)(s)?\b/i
    if regex =~ text
      return "kid"
    end
    
    # Check for mens
    regex = /\bmen(s)?\b/i
    if regex =~ text
      return "men"
    end

    # Check for womens
    regex = /\bwomen(s)?\b/i
    if regex =~ text
      return "women"    
    end

    return nil

  end
  
  def to_s
    "Department: #{id} #{name} (#{active})"
  end
  
end
