class FeedCategory < ActiveRecord::Base

  # A product has a feed_category
  has_many :products

  validates_presence_of :feed_category
  validates_presence_of :feed_id
  validates_inclusion_of :active, :in => [true, false]

  belongs_to :category
  belongs_to :feed

  def self.get_value_from_name(name)
    # Make sure there are no weird issues with format
    return name.nil? ? "" : name.downcase.strip
  end

  def self.get_unique_identifier(feed_id, feed_category, feed_subcategory, feed_product_group)
    fc_value = self.get_value_from_name(feed_category)
    fsc_value = self.get_value_from_name(feed_subcategory)
    fpg_value = self.get_value_from_name(feed_product_group)
    identifier = "#{feed_id}__#{fc_value}__#{fsc_value}__#{fpg_value}"
    return identifier
  end
  
  def name
    return "#{self.feed_category} #{self.feed_subcategory} #{self.feed_product_group}"
  end
  
  def to_s
    "Feed Category: #{id} - #{feed_category} - #{feed_subcategory} - #{feed_product_group} (#{active})"
  end

end
