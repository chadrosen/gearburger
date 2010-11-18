# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101116061418) do

  create_table "alternatives", :force => true do |t|
    t.integer "experiment_id"
    t.string  "content"
    t.string  "lookup",        :limit => 32
    t.integer "weight",                      :default => 1
    t.integer "participants",                :default => 0
    t.integer "conversions",                 :default => 0
  end

  add_index "alternatives", ["experiment_id"], :name => "index_alternatives_on_experiment_id"
  add_index "alternatives", ["lookup"], :name => "index_alternatives_on_lookup"

  create_table "brands", :force => true do |t|
    t.string   "name",                          :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",     :default => true,  :null => false
    t.boolean  "popular",    :default => false, :null => false
    t.integer  "map_to_id"
  end

  add_index "brands", ["map_to_id"], :name => "index_brands_on_map_to_id"
  add_index "brands", ["popular"], :name => "index_brands_on_popular"

  create_table "brands_users", :force => true do |t|
    t.integer  "brand_id",   :null => false
    t.integer  "user_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "brands_users", ["user_id", "brand_id"], :name => "index_brands_users_on_user_id_and_brand_id"

  create_table "campaigns", :force => true do |t|
    t.string   "public_id",                     :null => false
    t.string   "name",                          :null => false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",      :default => true, :null => false
  end

  add_index "campaigns", ["public_id"], :name => "index_campaigns_on_public_id", :unique => true

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

  create_table "clicks", :force => true do |t|
    t.string   "click_type",            :default => "product_email_link", :null => false
    t.integer  "user_id"
    t.datetime "created_at",                                              :null => false
    t.text     "source"
    t.integer  "version",               :default => 0,                    :null => false
    t.integer  "user_product_email_id"
    t.integer  "products_user_id"
    t.integer  "product_id"
  end

  add_index "clicks", ["created_at", "click_type"], :name => "index_clicks_on_created_at_and_click_type"

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

  create_table "email_day_preferences", :force => true do |t|
    t.integer "user_id",     :null => false
    t.string  "day_of_week", :null => false
  end

  add_index "email_day_preferences", ["day_of_week"], :name => "index_email_day_preferences_on_day_of_week"
  add_index "email_day_preferences", ["user_id", "day_of_week"], :name => "index_email_day_preferences_on_user_id_and_day_of_week"

  create_table "experiments", :force => true do |t|
    t.string   "test_name"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "experiments", ["test_name"], :name => "index_experiments_on_test_name"

  create_table "feed_categories", :force => true do |t|
    t.string   "feed_category",                        :null => false
    t.integer  "feed_id",                              :null => false
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",             :default => true, :null => false
    t.string   "value",                                :null => false
    t.string   "feed_subcategory"
    t.string   "feed_product_group"
  end

  add_index "feed_categories", ["category_id"], :name => "index_feed_categories_on_category_id"
  add_index "feed_categories", ["feed_id", "feed_category", "feed_subcategory", "feed_product_group"], :name => "feed_category_index", :unique => true

  create_table "feeds", :force => true do |t|
    t.string   "name",                         :null => false
    t.boolean  "active",     :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url"
  end

  create_table "friends", :force => true do |t|
    t.string   "name",                             :null => false
    t.text     "description",                      :null => false
    t.string   "blog_url",                         :null => false
    t.string   "gb_article_url"
    t.string   "image_url",                        :null => false
    t.boolean  "active",         :default => true, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "product_generation_summaries", :force => true do |t|
    t.integer  "new_products",    :default => 0, :null => false
    t.integer  "product_updates", :default => 0, :null => false
    t.integer  "new_cats",        :default => 0, :null => false
    t.integer  "new_brands",      :default => 0, :null => false
    t.integer  "product_errors",  :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "feed_id",                        :null => false
    t.integer  "price_changes",   :default => 0, :null => false
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
    t.decimal  "retail_price",        :precision => 10, :scale => 2, :default => 0.0,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sku",                                                                  :null => false
    t.integer  "department_id"
    t.integer  "brand_id",                                                             :null => false
    t.string   "large_image_url"
    t.string   "buy_url"
    t.decimal  "sale_price",          :precision => 10, :scale => 2, :default => 0.0,  :null => false
    t.decimal  "previous_sale_price", :precision => 10, :scale => 2, :default => 0.0
    t.datetime "price_changed_at"
    t.integer  "feed_id",                                                              :null => false
    t.integer  "feed_category_id",                                                     :null => false
    t.string   "manufacturer_id"
    t.boolean  "valid_sale_price",                                   :default => true, :null => false
    t.boolean  "valid_small_image",                                  :default => true, :null => false
  end

  add_index "products", ["brand_id"], :name => "index_products_on_brand_id"
  add_index "products", ["department_id"], :name => "index_products_on_department_id"
  add_index "products", ["feed_category_id"], :name => "index_products_on_feed_category_id"
  add_index "products", ["feed_id", "sku"], :name => "index_products_on_feed_id_and_sku", :unique => true
  add_index "products", ["price_changed_at"], :name => "index_products_on_price_changed_at"

  create_table "products_users", :force => true do |t|
    t.integer  "user_product_email_id",                    :null => false
    t.integer  "product_id",                               :null => false
    t.integer  "user_id",                                  :null => false
    t.boolean  "clicked",               :default => false, :null => false
    t.datetime "clicked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sales", :force => true do |t|
    t.integer  "click_id"
    t.string   "custom_tracking_code"
    t.integer  "order_id"
    t.string   "transaction_id",                                                          :null => false
    t.decimal  "transaction_amount",   :precision => 10, :scale => 2, :default => 0.0,    :null => false
    t.decimal  "total_commission",     :precision => 10, :scale => 2, :default => 0.0,    :null => false
    t.datetime "transaction_time",                                                        :null => false
    t.datetime "last_click_through"
    t.string   "merchant_name",                                                           :null => false
    t.integer  "merchant_id",                                                             :null => false
    t.string   "product_name"
    t.datetime "created_at",                                                              :null => false
    t.integer  "user_id"
    t.string   "sale_type",                                           :default => "sale", :null => false
  end

  add_index "sales", ["click_id"], :name => "index_sales_on_click_id"
  add_index "sales", ["transaction_id", "merchant_id"], :name => "index_sales_on_transaction_id_and_merchant_id"
  add_index "sales", ["user_id"], :name => "index_sales_on_user_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "user_invites", :force => true do |t|
    t.integer  "user_id",                              :null => false
    t.string   "email_address",                        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",         :default => "pending", :null => false
    t.datetime "sent_at"
    t.string   "error_msg"
    t.integer  "attempts",      :default => 0,         :null => false
  end

  add_index "user_invites", ["email_address"], :name => "index_user_invites_on_email_address"
  add_index "user_invites", ["user_id"], :name => "index_user_invites_on_user_id"

  create_table "user_product_emails", :force => true do |t|
    t.integer  "user_id",                                 :null => false
    t.boolean  "sent",                 :default => false, :null => false
    t.datetime "sent_at"
    t.boolean  "clicked",              :default => false, :null => false
    t.datetime "clicked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "viewed",               :default => false, :null => false
    t.datetime "viewed_at"
    t.integer  "products_users_count", :default => 0,     :null => false
  end

  add_index "user_product_emails", ["user_id"], :name => "index_user_product_emails_on_user_id"

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
    t.string   "state",                                                                   :default => "pending",                    :null => false
    t.datetime "deleted_at"
    t.boolean  "send_newsletter",                                                         :default => true
    t.string   "time_zone",                                                               :default => "Pacific Time (US & Canada)"
    t.text     "deactivation_reason",                                                                                               :null => false
    t.integer  "referral_id"
    t.string   "ip_address"
    t.string   "user_agent"
    t.string   "identity_hash"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "break_started_at"
    t.datetime "break_ends_at"
    t.integer  "campaign_id"
    t.integer  "fb_user_id"
    t.decimal  "min_discount",                             :precision => 10, :scale => 2, :default => 0.0,                          :null => false
    t.decimal  "min_price",                                :precision => 10, :scale => 2, :default => 0.0,                          :null => false
    t.decimal  "max_price",                                :precision => 10, :scale => 2, :default => 0.0,                          :null => false
    t.integer  "max_products_per_email",                                                  :default => 99,                           :null => false
    t.string   "referral_url"
  end

  add_index "users", ["campaign_id"], :name => "index_users_on_campaign_id"
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["referral_id"], :name => "index_users_on_referral_id"

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

end
