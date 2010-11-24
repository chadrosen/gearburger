require 'delayed_jobs'
module Admin

  class DelayedJobsController < AdminController
    
    def index
      @jobs = DelayedJob.order("created_at ASC").all
    end
    
    def destroy
      DelayedJob.delete(params[:id])
      redirect_to :back
    end
    
  end
end