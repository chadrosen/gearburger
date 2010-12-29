namespace :jobs do
  desc "Send product emails"
  task :generate_emails => :environment do
    Delayed::Job.enqueue DelayedJobs::ProductEmailJob.new  
  end
end