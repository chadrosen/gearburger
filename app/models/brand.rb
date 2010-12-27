class Brand < ActiveRecord::Base
  
  # A brand can belong to many users
  has_many :brands_users
  has_many :users, :through => :brands_users
  
  # A product has a brand..
  has_many :products
  
  validates_presence_of :name
  validates_uniqueness_of :name # Name must be unique

  validates_inclusion_of :active, :in => [true, false]  

  # A brand can be mapped to another brand. Essentially it is invalid
  belongs_to :mapped_to, :class_name => "Brand", :foreign_key => "map_to_id"
  has_many :mapped_to_me, :class_name => "Brand", :primary_key => "id", :foreign_key => "map_to_id"
    
  def self.map_brand(old_brand, new_brand)
    # Map one brand to a new brand.. move it's products over also.
    # NOTE: This is destructive and irreversible
    # NOTE 2: If the new brand is nil we destroy the relationship but we don't mess with products
    
    # Don't let a circular reference happen
    return if old_brand == new_brand.mapped_to
    
    # Doesn't make sense to map the same brand to itself
    return if old_brand == new_brand
    
    Product.transaction do
      
      # Update products with a new brand. Does not run if the new_brand is nil
      Product.update_all(["brand_id = ?", new_brand.id], ["brand_id = ?", old_brand.id])
      
      # Move all of the users from one brand to another
      BrandsUser.update_all(["brand_id = ?", new_brand.id], ["brand_id = ?", old_brand.id])
      
      # Map brand and inactivate old brand
      old_brand.mapped_to = new_brand
      old_brand.active = false
      old_brand.save!
    end
  end
  
  def self.get_brand_key(name)
    # Make sure brand name is a canonicalized (sp?) key 
    return name.delete(" ").delete("'").downcase
  end
      
  def self.get_brands(options = {})
    # Get a list of brands.. If we passed a category id only get brands in that category..
    options[:category_ids] ? Brand.brands_by_category(options[:category_ids]) : Brand.where(:active => true).order("name ASC").all 
  end
  
  def self.brands_by_category(category_ids, active = true)
        
    # Get a list of brands filtered by by category
    sql = "
    SELECT
      bra.*
    FROM
      brands as bra,
      (SELECT
        distinct(pr.brand_id) as id
      FROM
        products as pr
      WHERE
        pr.category_id IN (?)) as br_ids
    WHERE
      br_ids.id = bra.id
      AND bra.active = ?
      AND popular = FALSE
    ORDER BY
      bra.name ASC
    "
    return Brand.find_by_sql([sql, category_ids, active])
  end
  
  def self.group_by_alpha(items)
    
    # Create the datastucture
    grouped_data = {}
    # Alpha
    ('a'..'z').to_a.each { |l| grouped_data[l] = [] }
    # Everything else
    grouped_data[''] = []

    items.each do |mod|

      l = mod.name[0].chr.downcase
      # If the letter is alpha but it in the letter slot.
      if /[a-z]|[A-z]/ =~ l
        grouped_data[l] << mod
      else
        grouped_data[''] << mod
      end
    end

    return grouped_data
  end
  
  def self.popular_brands(options = {})

    limit = options[:limit] || 20

    # Get a list of the most popular brands
    sql = "
    SELECT 
      br.id,
      count(*) as c
    FROM
      brands_users as bu, 
      brands as br
    WHERE 
      br.id = bu.brand_id
      AND br.active = TRUE
    GROUP BY
      bu.brand_id,
      br.id 
    ORDER BY
      c DESC
    LIMIT 
      #{limit}
    "
    # Get the ids and make sure they are integers instead of strings
    ids = Brand.connection.select_values(sql).map { |i| i.to_i }
    
    # Uh oh.. this isn't sorted!!
    brands = Brand.find(ids) 
    
    brands.sort_by {|b| ids.index(b.id).to_i }    
  end
  
  def to_s
    "Brand: #{id} - #{name} (#{active})"
  end
  
end
