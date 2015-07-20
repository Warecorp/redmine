# config valid only for Capistrano 3.1
lock '3.3.5'

deploy_dir  = "/home/redmine/app"

set :scm, :git
set :git_strategy, Capistrano::Git::SubmoduleStrategy
set :repo_url, 'git@github.com:Warecorp/redmine.git'
set :branch, fetch(:revision) || ENV['branch'] || :develop
set :deploy_to, deploy_dir
set :pty, true

namespace :deploy do

  desc 'Setup'
  task :setup do
    on roles(:all) do
      ['config', 'run', 'log', 'socket', 'system'].each do |shared_dir|
        execute "mkdir -p #{shared_path}/#{shared_dir}/"
      end

      ['database.yml', 'trackmine.yml'].each do |file|
        upload! "config/deploy/files/#{fetch(:stage)}/#{file}", "#{shared_path}/config/#{file}"
      end
    end
  end

  desc 'Create symlink'
  task :symlink do
    on roles(:all) do
      ['database.yml', 'trackmine.yml', 'unicorn.rb'].each do |file|
        execute "ln -s #{shared_path}/config/#{file} #{release_path}/config/#{file}"
      end
      execute "ln -s #{shared_path}/config/secret_token.rb #{release_path}/config/initializers/secret_token.rb"
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo service unicorn restart"
    end
  end

  desc 'Migrate plugins'
  task :migrate_plugins do
    on primary fetch(:migration_role) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, "redmine:plugins:migrate"
        end
      end
    end
  end

  desc 'Clear cache'
  task :clear_cache do
    on roles(:util) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, "cache:clear"
        end
      end
    end
  end

  before :setup,    'deploy:updating'
  after :updating,  'deploy:symlink'
  after 'deploy:migrate', 'deploy:migrate_plugins'
  after :finishing, 'deploy:cleanup'
  after 'deploy:cleanup', 'deploy:restart'

end
