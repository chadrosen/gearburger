module Admin

  class AdminController < ApplicationController
    
    # This controller extends the normal application controller. We want the helpers and stuff
    # but we want to ignore the filters from that controller.
    
    # TODO: Figure out how to skip all filters automatically... or just make this its own controller
    skip_filter :set_layout_data, :set_abingo_identity
    before_filter :ga_cookie # run the filters in this class
    
    # Use the admin layout
    layout "admin"
    
  protected

    def ga_cookie
      # Anytime anyone hits a admin page set the google analytics ignore cookie.
      # Doesn't log admin analytics pages for these users
      cookies[:ga_ignore] = "ignore_me"
    end
  end
end