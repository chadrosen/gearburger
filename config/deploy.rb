# So, we can have different env, staging, product, etc
set :stages, %w(development staging production)
require 'capistrano/ext/multistage'

set :application, "gearburger"

# Credentials for checking out code
set :scm, :subversion
set :scm_username, "chadr"
set :scm_password, "t34b4g"

namespace :deploy do
    
  def remote_file_exists?(full_path)
    'true' ==  capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
  end
    
  before "deploy:update_code", "deploy:check"
  after "deploy:update_code", "deploy:build_assets"
  after "deploy:update_code", "deploy:fix_permissions"
              
  desc "Create asset javascript/css asset packages" 
  task :build_assets, :roles => [:web] do
    # Change the permissions of the latest release if group_writable
    # had a problem with trying to run the asset builder
    # http://www.theymightbe.com/node/19
    run "chmod -R g+w #{release_path}"
    run "chown -R gearburger #{release_path}"     
    run "cd #{release_path} && #{sudo} rake asset:packager:build_all"    
  end
      
  desc "Make sure logs have the correct permissions"
  task :fix_permissions, :roles => :web do
    run "sudo chown -R gearburger:svn #{shared_path}/log"
    
    # Make sure the product emails directory exists... 
    # TODO: this shouldn't be a hard coded name. Can we use OPTIONS[:product_emails]???
    unless remote_file_exists? "#{shared_path}/product_emails"
      run "sudo mkdir #{shared_path}/product_emails"
      run "sudo chmod -R 777 #{shared_path}/product_emails"
    end
    
    # The cache dir needs to exist in the shared dir and not per release
    unless remote_file_exists? "#{shared_path}/cache"
      run "sudo mkdir #{shared_path}/cache"
      run "sudo chmod -R 777 #{shared_path}/cache"
    end
    
    run "ln -s #{shared_path}/cache #{release_path}/tmp/cache"
  end
      
  desc "Tell apache to restart the server"
  task :start, :roles => :app do
    # Touch the restart.txt file. This tells passenger to reload the app 
    run "touch #{current_release}/tmp/restart.txt"    
  end
        
  desc "run all release related commands"
  task :all do
    transaction do
      update
      migrate
      start
    end
  end
    
end  