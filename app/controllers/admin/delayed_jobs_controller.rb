require 'delayed_jobs'
module Admin

  class DelayedJobsController < AdminController
    
    def index
      @jobs = Delayed::Job.order("created_at ASC").all
    end
    
    def destroy
      Delayed::Job.delete(params[:id])
      redirect_to :back
    end
        
  end
end