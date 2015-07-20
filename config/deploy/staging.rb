set :rails_env, 'staging'
set :branch,    fetch(:branch, 'develop')

server 'trainer.warecorp.com', user: 'redmine', roles: [:app, :db, :util, :web, :assets]
