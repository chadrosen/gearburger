class CreateFriends < ActiveRecord::Migration
  def self.up
    create_table :friends do |t|
      t.string :name, :null => false
      t.text :description, :null => false
      t.string :blog_url, :null => false
      t.string :gb_article_url, :null => true
      t.string :image_url, :null => false
      t.boolean :active, :null => false, :default => true
      t.timestamps
    end
    
    Friend.create!(:name => "stuffmikelikes.com", :description => "Gear, Gadgets and Everything in Between…", 
      :blog_url => "http://stuffmikelikes.com",
      :gb_article_url => "http://stuffmikelikes.com/2009/08/05/gearburger-com-get-custom-alerts-when-gear-goes-on-sale/",
      :image_url => "http://sphotos.ak.fbcdn.net/hphotos-ak-snc1/hs198.snc1/6720_107603263606_107589848606_2099263_3492433_n.jpg")
  end

  def self.down
    drop_table :friends
  end
end
