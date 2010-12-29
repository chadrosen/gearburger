# Add facebooker tasks here..
#require 'tasks/facebooker'

namespace :db do
  desc "drop, create, migrate, and load fixtures"
  task :reset do
      Rake::Task["db:drop"].invoke
      Rake::Task["db:create"].invoke
      Rake::Task["db:migrate"].invoke
      Rake::Task["db:fixtures:load"].invoke
  end

  desc "Delete old sessions from database."
  task :delete_old_sessions => :environment do
   hours_ago = ENV['hours_ago'] ? ENV['hours_ago'].to_i : 5   
   ActiveRecord::SessionStore::Session.delete_all(["updated_at < ?", hours_ago.hours.ago.utc])
  end
end