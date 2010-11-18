# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:

# See http://robsanheim.com/2007/05/10/making-capistrano-deploy-to-mac-os-x/
# for local development info

set :repository,  "https://chadr@gearburger.svn.cvsdude.com/gearburger/trunk"

# No need to use sudo rights?? Right?
set :use_sudo, true

# Log in as me
set :user, "crosen"

server "localhost", :app, :web, :db, :primary => true

set :deploy_to, "/var/www/#{application}_development"
set :rails_env, "development"