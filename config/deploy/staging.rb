# No need to use sudo rights?? Right?
set :use_sudo, true

set :repository,  "https://chadr@gearburger.svn.cvsdude.com/gearburger/trunk"

server "hulk.packethole.com", :app, :web, :db, :primary => true

# Log in as gearburger
set :user, "gearburger"

set :deploy_to, "/var/www/#{application}_staging"
set :rails_env, "staging"