set :rails_env, 'staging'
set :branch,    fetch(:branch, 'develop')
set :keep_releases, 3

server 'qpharmetra-stage.warecorp.com', user: 'redmine', roles: [:app, :db, :util, :web, :assets]
