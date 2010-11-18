# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:

set :repository,  "https://chadr@gearburger.svn.cvsdude.com/gearburger/trunk"

# No need to use sudo rights?? Right?
set :use_sudo, true

server "hulk.packethole.com", :app, :web, :db, :primary => true

# Log in as gearburger
set :user, "gearburger"

set :deploy_to, "/var/www/#{application}"
set :rails_env, "production"
