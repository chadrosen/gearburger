Gearburger::Application.routes.draw do

  root :to => "users#new"

  resources :users, :only => [:new, :show] do
    member do
      get 'brands'
      get 'categories'
      get 'departments'
      get 'resend_activation_email'
      get 'reactivate_account'
    end 
  end
    
  match :invite_friends, :to => "friends#invite_friends", :via => :get
  scope :via => "post" do
    match :invite_friends, :to => "friends#invite_friends_submit"
    match :get_friends, :to => "friends#get_friends"
  end
          
  # Stuff I don't want to be part of the user object but exists on the controller
  controller "users" do
        
    scope :via => "get" do
      match :gear_bin
      match :more_gear
      match :fb_login
      match :fb_create
      match :toggle_newsletter
      match :signup
      match :signup_complete
      match :clear_breather
      match :gearguide
      match :lost_password
      match :change_password
      match :email_preferences 
      match :deactivate_account
      match :account_preferences 
      match :take_a_breather      
    end
        
    scope :via => "post" do 
      match :lost_password, :to => "users#lost_password_submit"
      match :change_password, :to => "users#change_password_submit"            
      match :departments_submit, :to => "users#departments_submit"
      match :brands_submit, :to => "users#brands_submit"
      match :categories_submit, :to => "users#categories_submit"
      match :email_preferences, :to => "users#email_preferences_submit" 
      match :deactivate_account, :to => "users#deactivate_account_submit"
      match :account_preferences, :to => "users#account_preferences_submit"  
      match :take_a_breather, :to => "users#take_a_breather_submit"      
    end
    
    match '/activate/:activation_code', :as => "activate", :to => 'users#activate'
    
    # Single route that lets me "generically" edit user items like brands, categories, departments in the same url
    match "/user/:action", :as => "item_edit", :to => "users#item_edit"
  end
  
  # Misc webapp stuff
  controller "misc" do
    match :about
    match :faq
    match :sitemap
    match :invite_terms
    match :privacy
  end
  
  # Map products
  resources :products, :only => [:show]  
  match "/ppep/:user_product_email_id", :as => "product_price_email_pixel", :to => "products#product_price_email_pixel"
  match '/pe', :as => "product_email_redirector",  :to => "products#product_email_redirector"
  match '/pr/:product_id/:source', :as => "product_redirector", :to => "products#product_redirector", :source => nil 
  
  # Signup, login, logout etc
  match :logout, :to => 'sessions#destroy'
  match :login, :to => 'sessions#new', :via => :get
  match :login, :to => 'sessions#create', :via => :post 

  # Sub-resources of admin
  namespace :admin do
    
    match "/", :to => "stats#index", :as => :home
    
    resources :campaigns, :sales, :clicks, :friends, :categories, :departments
        
    resources :products do
      member do 
        get "feed_results" 
        get "product_prices"
      end 
      collection do
        get "product_changes"
        get "validation_results"
      end
    end
    
    # TODO: move this up into products?
    match "/user_emails", :as => "user_emails",  :to => "products#user_emails"
    
    resources :brands, :except => [:destroy] do
      collection do
        get "popular"
      end
    end
    
    resources :feeds, :except => [:destroy, :show] do
      collection do
        get "pull"
      end
    end
    
    resources :users do 
      member do
        get "login"
        get "deactivate"
        get "activate" 
        get "email_product_alerts"
        get "invited_users"
      end
      collection do 
        get "reasons"
        get "giftcards"
      end
    end
    
    # admin contest stuff
    resources :contests, :shallow => true do
      resources :captions, :shallow => true do
        resources :votes
      end
    end
    
    resources :user_product_emails do
      member do
        get "email_user"
      end
    end
    
    resources :feed_categories do 
      collection do
        post "multi_update"
      end
    end
            
    # A/B teting stuff
    match "/abingo/:action/:id", :as => "abingo_test", :to => "abingo"  
        
    controller "stats" do        
      match :product_generation
      match :summary
      match :avantlink_stats
      match :google_stats
      match :monthly_users
      match :stats_over_time
      match :campaign_stats
      match :user_behavior
      match :click_stats
    end    
  end
  
  # contest stuff
  resources :contests, :only => :index do
    resources :captions, :only => [:create] do
      resources :votes, :only => [:create]
    end
  end
    
end