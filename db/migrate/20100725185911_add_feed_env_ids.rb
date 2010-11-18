class AddFeedEnvIds < ActiveRecord::Migration
  def self.up
    add_column(:feeds, :development_url, :string, :null => true)
    add_column(:feeds, :staging_url, :string, :null => true)
    add_column(:feeds, :production_url, :string, :null => true)
    add_column(:feeds, :test_url, :string, :null => true)
    
    Feed.reset_column_information
    
    #DEV
    d = {
      "backcountry.com" => 22179,
      "dogfunk.com" => 22233,
      "hucknroll.com" => 38325,
      "realcyclist.com" => 38337,
      "evogear.com" => 40501,
      "moosejaw" => 40513,
      "altrec.com outdoors (new)" => 40525,
      "altrecoutlet.com" => 40537,
      "campsaver.com" => 40549,
      "departmentofgoods.com" => 40797,
      "patagonia.com" => 41241,
      "gearx.com" => 41265,
      "bike.com" => 41253, 
      "skis.com" => 41277,
      "usoutdoorstore.com" => 41289, 
      "giantnerd" => 41321,
      "half-moon outfitters" => 41333,
      "konasports.com" => 41345,
      "outdoorbasics.com" => 41357,
      "o2 gear shop" => 41369,
      "snowboards.net" => 41381,
      "masseysoutfitters.com" => 41393,
      "ramseyoutdoor.com" => 41405,
      "fontanasports.com" => 41417,
      "paragonsports.com" => 41429,
      "marine products" => 41697
    }
    
    # staging
    s = {
      "backcountry.com" => 22183,
      "dogfunk.com" => 22229,
      "hucknroll.com" => 40485,
      "realcyclist.com" => 40489,
      "evogear.com" => 40497,
      "moosejaw" => 40509,
      "altrec.com outdoors (new)" => 40521,
      "altrecoutlet.com" => 40533,
      "campsaver.com" => 40545,
      "departmentofgoods.com" => 40801,
      "patagonia.com" => 41245,
      "gearx.com" => 41269,
      "bike.com" => 41257, 
      "skis.com" => 41281,
      "usoutdoorstore.com" => 41293,
      "giantnerd" => 41325,
      "half-moon outfitters" => 41337,
      "konasports.com" => 41349,
      "outdoorbasics.com" => 41361,
      "o2 gear shop" => 41373,
      "snowboards.net" => 41385,
      "masseysoutfitters.com" => 41397,
      "ramseyoutdoor.com" => 41409,
      "fontanasports.com" => 41421,
      "paragonsports.com" => 41433,
      "marine products" => 41701
    }
    
    # production
    p = {
      "backcountry.com" => 22187,
      "dogfunk.com" => 22225,
      "hucknroll.com" => 38333,
      "realcyclist.com" => 38329,
      "evogear.com" => 40493,
      "moosejaw" => 40505,
      "altrec.com outdoors (new)" => 40517,
      "altrecoutlet.com" => 40529,
      "campsaver.com" => 40541,
      "departmentofgoods.com" => 40805,
      "patagonia.com" => 41249,
      "gearx.com" => 41273,
      "bike.com" => 41261, 
      "skis.com" => 41285,
      "usoutdoorstore.com" => 41297,
      "giantnerd" => 41329,
      "half-moon outfitters" => 41341,
      "konasports.com" => 41353,
      "outdoorbasics.com" => 41365,
      "o2 gear shop" => 41377,
      "snowboards.net" => 41389,
      "masseysoutfitters.com" => 41401,
      "ramseyoutdoor.com" => 41413,
      "fontanasports.com" => 41425,
      "paragonsports.com" => 41437,
      "marine products" => 41705
    }
    
    # Migrate existing feeds
    Feed.find(:all).each do |f|
      
      name = f.name.downcase
      du = d[name]
      su = s[name]
      pu = p[name]
      tu = d[name] # same as dev (for now) 
      
      f.development_url = "http://datafeed.avantlink.com/download_feed.php?auth=b94ac9d3911f69692d14e0cefe1fb960&id=#{du}"
      f.staging_url = "http://datafeed.avantlink.com/download_feed.php?auth=b94ac9d3911f69692d14e0cefe1fb960&id=#{su}"
      f.production_url = "http://datafeed.avantlink.com/download_feed.php?auth=b94ac9d3911f69692d14e0cefe1fb960&id=#{pu}"
      f.test_url = "http://datafeed.avantlink.com/download_feed.php?auth=b94ac9d3911f69692d14e0cefe1fb960&id=#{du}"
      f.save!
    end
    
    remove_column(:feeds, :url)
  end

  def self.down
  end
end
