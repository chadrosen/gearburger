class CreateSchema < ActiveRecord::Migration

  def self.up

    create_table "alerts", :force => true do |t|
      t.integer  "product_id",                                                 :null => false
      t.integer  "feed_id",                                                    :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.decimal  "sale_price", :precision => 10, :scale => 2, :default => 0.0, :null => false
    end

    add_index "alerts", ["created_at"], :name => "index_alerts_on_created_at"
    add_index "alerts", ["product_id"], :name => "index_feeds_products_on_product_id"

    create_table "alerts_users", :force => true do |t|
      t.integer  "alert_id",                      :null => false
      t.integer  "user_id",                       :null => false
      t.integer  "product_id",                    :null => false
      t.integer  "feed_id",                       :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "clicked",    :default => false, :null => false
      t.datetime "clicked_at"
      t.boolean  "sent",       :default => false, :null => false
      t.datetime "sent_at"
    end

    add_index "alerts_users", ["clicked"], :name => "index_alerts_users_on_clicked"
    add_index "alerts_users", ["sent"], :name => "index_alerts_users_on_sent"
    add_index "alerts_users", ["user_id", "product_id"], :name => "index_alerts_users_on_user_id_and_product_id"

    create_table "blocked_products", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "user_id",    :null => false
      t.integer  "product_id", :null => false
    end

    add_index "blocked_products", ["user_id", "product_id"], :name => "index_blocked_products_on_user_id_and_product_id"

    create_table "brands", :force => true do |t|
      t.string   "name",                          :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "active",     :default => true,  :null => false
      t.string   "permalink",                     :null => false
    end

    add_index "brands", ["permalink"], :name => "index_brands_on_permalink"

    create_table "brands_users", :force => true do |t|
      t.integer  "brand_id",   :null => false
      t.integer  "user_id",    :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "brands_users", ["user_id", "brand_id"], :name => "index_brands_users_on_user_id_and_brand_id"

    create_table "captions", :force => true do |t|
      t.integer  "contest_id",                           :null => false
      t.text     "description",                          :null => false
      t.integer  "user_id",                              :null => false
      t.integer  "vote_count",         :default => 0,    :null => false
      t.boolean  "active",             :default => true, :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "invalid_vote_count", :default => 0,    :null => false
    end

    add_index "captions", ["contest_id", "user_id"], :name => "index_captions_on_contest_id_and_user_id", :unique => true
    add_index "captions", ["contest_id"], :name => "index_captions_on_contest_id"

    create_table "categories", :force => true do |t|
      t.string   "name",                         :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "active",     :default => true, :null => false
      t.string   "value",                        :null => false
    end

    create_table "categories_users", :force => true do |t|
      t.integer  "user_id",     :null => false
      t.integer  "category_id", :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "categories_users", ["user_id", "category_id"], :name => "index_categories_users_on_user_id_and_category_id"

    create_table "contests", :force => true do |t|
      t.string   "image_url",                                                        :null => false
      t.datetime "start_time",                                                       :null => false
      t.datetime "end_time",                                                         :null => false
      t.boolean  "active",                                        :default => false, :null => false
      t.string   "prize_url"
      t.string   "prize_name",                                                       :null => false
      t.decimal  "prize_price",    :precision => 10, :scale => 2, :default => 0.0,   :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "captions_count",                                :default => 0,     :null => false
    end

    create_table "coupons", :force => true do |t|
      t.string   "title",                         :null => false
      t.text     "description"
      t.string   "url",                           :null => false
      t.boolean  "active",      :default => true, :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "departments", :force => true do |t|
      t.string   "name",                         :null => false
      t.boolean  "active",     :default => true, :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "value"
    end

    create_table "departments_users", :force => true do |t|
      t.integer  "user_id",       :null => false
      t.integer  "department_id", :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "departments_users", ["user_id", "department_id"], :name => "index_departments_users_on_user_id_and_department_id"

    create_table "feeds", :force => true do |t|
      t.string   "name",                                                            :null => false
      t.string   "url",                                                             :null => false
      t.boolean  "active",                                      :default => true
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "affiliate_url"
      t.enum     "feed_type",     :limit => [:product, :alert], :default => :alert
    end

    create_table "followed_products", :force => true do |t|
      t.integer  "user_id",    :null => false
      t.integer  "product_id", :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "followed_products", ["product_id"], :name => "index_followed_products_on_product_id"
    add_index "followed_products", ["user_id"], :name => "index_followed_products_on_user_id"

    create_table "product_generation_summaries", :force => true do |t|
      t.string   "feed_source",                    :null => false
      t.integer  "new_products",    :default => 0, :null => false
      t.integer  "product_updates", :default => 0, :null => false
      t.integer  "new_cats",        :default => 0, :null => false
      t.integer  "new_brands",      :default => 0, :null => false
      t.integer  "product_errors",  :default => 0, :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "product_prices", :id => false, :force => true do |t|
      t.integer  "product_id",                                                 :null => false
      t.datetime "created_at",                                                 :null => false
      t.decimal  "price",      :precision => 10, :scale => 2, :default => 0.0, :null => false
    end

    add_index "product_prices", ["created_at", "product_id"], :name => "index_product_prices_on_created_at_and_product_id"
    add_index "product_prices", ["product_id", "created_at"], :name => "index_product_prices_on_product_id_and_created_at"

    create_table "products", :force => true do |t|
      t.string   "product_name"
      t.string   "small_image_url"
      t.decimal  "retail_price",        :precision => 10, :scale => 2, :default => 0.0, :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "sku",                                                                 :null => false
      t.integer  "category_id",                                                         :null => false
      t.integer  "department_id"
      t.integer  "brand_id",                                                            :null => false
      t.string   "permalink",                                                           :null => false
      t.string   "large_image_url"
      t.string   "short_description"
      t.string   "keywords"
      t.string   "buy_url"
      t.integer  "recent_alert_id"
      t.decimal  "sale_price",          :precision => 10, :scale => 2, :default => 0.0, :null => false
      t.decimal  "previous_sale_price", :precision => 10, :scale => 2, :default => 0.0
      t.datetime "price_changed_at"
    end

    add_index "products", ["brand_id"], :name => "index_products_on_brand_id"
    add_index "products", ["category_id"], :name => "index_products_on_category_id"
    add_index "products", ["department_id"], :name => "index_products_on_department_id"
    add_index "products", ["permalink"], :name => "index_products_on_permalink"
    add_index "products", ["price_changed_at"], :name => "index_products_on_price_changed_at"
    add_index "products", ["sku"], :name => "index_products_on_sku", :unique => true

    create_table "recent_alerts", :force => true do |t|
      t.integer  "feed_id",    :null => false
      t.integer  "product_id", :null => false
      t.integer  "alert_id",   :null => false
      t.datetime "created_at", :null => false
    end

    create_table "sessions", :force => true do |t|
      t.string   "session_id", :null => false
      t.text     "data"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
    add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

    create_table "users", :force => true do |t|
      t.string   "email",                     :limit => 100
      t.string   "crypted_password",          :limit => 40
      t.string   "salt",                      :limit => 40
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "remember_token",            :limit => 40
      t.datetime "remember_token_expires_at"
      t.string   "activation_code",           :limit => 40
      t.datetime "activated_at"
      t.enum     "state",                     :limit => [:pending, :active, :inactive], :default => :pending
      t.datetime "deleted_at"
      t.boolean  "send_newsletter",                                                     :default => true
      t.string   "time_zone",                                                           :default => "Pacific Time (US & Canada)"
      t.integer  "email_start_time",                                                    :default => 9,                            :null => false
      t.integer  "email_end_time",                                                      :default => 17,                           :null => false
      t.string   "email_days",                                                          :default => "MF",                         :null => false
      t.text     "deactivation_reason",                                                                                           :null => false
      t.boolean  "send_alert_email",                                                    :default => true,                         :null => false
      t.boolean  "send_price_email",                                                    :default => false,                        :null => false
    end

    add_index "users", ["email"], :name => "index_users_on_email", :unique => true
    add_index "users", ["send_alert_email"], :name => "index_users_on_send_alert_email"
    add_index "users", ["send_price_email"], :name => "index_users_on_send_price_email"

    create_table "votes", :force => true do |t|
      t.integer  "contest_id",                     :null => false
      t.integer  "caption_id",                     :null => false
      t.text     "user_agent"
      t.string   "ip_address"
      t.string   "cookie"
      t.string   "flash_cookie"
      t.boolean  "is_valid",     :default => true, :null => false
      t.text     "reason"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "votes", ["contest_id", "cookie"], :name => "index_votes_on_contest_id_and_cookie"
    add_index "votes", ["contest_id", "flash_cookie"], :name => "index_votes_on_contest_id_and_flash_cookie"
    
    # This is a weird rails thing.. Make sure departments is created by resetting the column info
    Department.reset_column_information
    Department.create!(:name => "Men's Gear", :value => "men", :active => 1)
    Department.create!(:name => "Women's Gear", :value => "women", :active => 1)
    Department.create!(:name => "Kid's Gear", :value => "kid", :active => 1)
    
    Feed.reset_column_information
    
    url = "http://datafeed.avantlink.com/download_feed.php?auth=b94ac9d3911f69692d14e0cefe1fb960&id="
    
    Feed.create!(:name => "Backcountry Outlet", :url => "#{url}22195", :feed_type => :product)
    Feed.create!(:name => "Backcountry.com", :url => "#{url}22187", :feed_type => :product)
    Feed.create!(:name => "DogFunk.com", :url => "#{url}22225", :feed_type => :product)
    Feed.create!(:name => "HucknRoll.com", :url => "#{url}38333", :feed_type => :product)
    Feed.create!(:name => "RealCyclist.com", :url => "#{url}38329", :feed_type => :product)
    
    Feed.create!(:name => "Tramdock", :affiliate_url => "http://www.avantlink.com/click.php?tt=cl&amp;mi=10062&amp;pw=13265&amp;url=http%3A%2F%2Ftramdock.com", 
      :url => "http://www.tramdock.com/docs/tramdock/rssaff.xml", :active => 1)
    Feed.create!(:name => "Whiskey Militia", :affiliate_url => "http://www.avantlink.com/click.php?tt=cl&amp;mi=10269&amp;pw=13265&amp;url=http%3A%2F%2Fwhiskeymilitia.com", 
      :url => "http://www.whiskeymilitia.com/docs/wm/rssaff.xml", :active => 1)
    Feed.create!(:name => "Steep and Cheap", :affiliate_url => "http://www.avantlink.com/click.php?tt=cl&amp;mi=10268&amp;pw=13265&amp;url=http%3A%2F%2Fsteepandcheap.com", 
      :url => "http://www.steepandcheap.com/docs/steepcheap/rssaff.xml", :active => 1)
    Feed.create!(:name => "Brociety", :affiliate_url => "http://www.avantlink.com/click.php?tt=cl&amp;mi=10417&amp;pw=13265&amp;url=http%3A%2F%2Fbrociety.com", 
      :url => "http://www.brociety.com/docs/brociety/rssaff.xml", :active => 1)
    Feed.create!(:name => "Chainlove", :affiliate_url => "http://www.avantlink.com/click.php?tt=cl&amp;mi=10271&amp;pw=13265&amp;url=http%3A%2F%2Fchainlove.com", 
      :url => "http://www.chainlove.com/docs/chainlove/rssaff.xml", :active => 1)
    Feed.create!(:name => "Bonktown", :affiliate_url => "http://www.avantlink.com/click.php?tt=cl&amp;mi=10381&amp;pw=13265&amp;url=http%3A%2F%2Fbonktown.com", 
      :url => "http://www.bonktown.com/docs/bonktown/rssaff.xml", :active => 1)
  end

  def self.down
  end
end
