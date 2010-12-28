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
    
    def manually_send_emails
      # Manaully send the product emails
      Delayed::Job.enqueue DelayedJobs::ProductEmailJob.new
      redirect_to :back
    end
    
    def pull_sales_report
      # TODO: Let user select dates
      Delayed::Job.enqueue DelayedJobs::SaleProcessorJob.new(:start_date => Date.today - 3, 
        :end_date => Date.today)
        
      flash[:notice] = "Sales processor job queued up"
      redirect_to :back
    end
    
    def clear_sendgrid
      Delayed::Job.enqueue DelayedJobs::ClearEmailJob.new
      redirect_to :back
    end
            
  end
end