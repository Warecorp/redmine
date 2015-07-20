# config valid only for Capistrano 3.1
lock '3.3.5'

deploy_dir  = "/home/redmine/app"

set :scm, :git
set :repo_url, 'git@github.com:Warecorp/redmine.git'
set :branch, fetch(:revision) || ENV['branch'] || :develop
set :deploy_to, deploy_dir
set :pty, true

namespace :deploy do

  desc 'Setup'
  task :setup do
    on roles(:all) do
      execute "mkdir -p #{shared_path}/config/"
      execute "mkdir -p #{deploy_dir}/run/"
      execute "mkdir -p #{deploy_dir}/log/"
      execute "mkdir -p #{deploy_dir}/socket/"
      execute "mkdir -p #{shared_path}/system"

      upload! "config/deploy/files/#{fetch(:stage)}/database.yml", "#{shared_path}/config/database.yml"
      upload! "config/deploy/files/#{fetch(:stage)}/trackmine.yml", "#{shared_path}/config/trackmine.yml"

    end
  end

  desc 'Create symlink'
  task :symlink do
    on roles(:all) do
      execute "ln -s #{shared_path}/config/database.yml #{release_path}/config/database.yml"
      execute "ln -s #{shared_path}/config/trackmine.yml #{release_path}/config/trackmine.yml"
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo service unicorn restart"
    end
  end

  # desc 'DB dump'
  # task :db_dump do
  #   on roles(:db) do
  #     puts "\n\tCreate db dump"
  #     if fetch(:rails_env) == 'production'
  #       execute "pg_dump intranet_prod > ~/db_archive/#{Time.now.to_i.to_s}_intranet_prod.sql", shell: "/bin/bash"
  #       puts "\n\t\tCreated db dump."
  #     end
  #   end
  # end

  after :finishing, 'deploy:cleanup'
  after :finishing, 'deploy:restart'
  after :updating,  'deploy:symlink'
#  after 'deploy:symlink', 'bundler:install'
#  after 'bundler:install', 'deploy:create_deplayed_job'
#  before 'deploy:start_delayed_jobs', 'deploy:add_delayed_jobs'
 # after :finishing, 'deploy:start_delayed_jobs'

  #after 'deploy:stop_delayed_jobs', 'deploy:clear_delayed_jobs'
  # before :updating, 'deploy:stop_delayed_jobs'
  # before :setup,    'deploy:starting'
  # before :updating, 'deploy:db_dump'
  before :setup,    'deploy:updating'
  # before :setup,    'bundler:install'

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
