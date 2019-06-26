require_relative "deploy/aws_utils"
require_relative "deploy/instance_utils"
require_relative "deploy/syns_env"

lock "~> 3.11.0"

set :application, "demo_deploy"
set :repo_url, "git@github.com:oBuiVanQuynh/demo_deploy.git"
set :assets_roles, [:app]
set :deploy_ref, ENV["DEPLOY_REF"]
set :deploy_ref_type, ENV["DEPLOY_REF_TYPE"]
set :bundle_binstubs, nil

if fetch(:deploy_ref)
  set :branch, fetch(:deploy_ref)
else
  raise "Please set $DEPLOY_REF"
end

set :rbenv_type, :user
set :rbenv_ruby, "#{ENV['RB_VERSION']}"

set :deploy_to, "/usr/local/rails_apps/#{fetch :application}"

set :deployer, ENV["DEPLOYER"] || "ec2-user"

platform = ENV["PLATFORM"] || "aws"

set :platform, platform

set :settings, YAML.load_file(ENV["SETTING_FILE"] ||"config/deploy/settings.yml")
set :instances, platform == "aws" ? get_ec2_targets : get_instance_targets unless ENV["LOCAL_DEPLOY"]

set :deploy_via,      :remote_cache
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true

upload_env

default_linked_files = [
  "config/application.yml",
  "config/database.yml",
  "config/master.key",
  "config/credentials.yml.enc",
]
settings_linked_files = fetch(:settings)["linked_files"]
default_linked_files.concat(settings_linked_files) if settings_linked_files
# Default value for :linked_files is []
append :linked_files, *default_linked_files

set :linked_dirs, %w(log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/uploads)

upload_env

namespace :deploy do
  desc "link application.yml"
  task :link_env do
    on roles(:all) do
      update_env
    end
  end
  before :migrate, :link_env

  desc "create database"
  task :create_database do
    on roles(:db) do |host|
      within "#{release_path}" do
        with rails_env: ENV["RAILS_ENV"] do
          execute :rake, "db:create"
        end
      end
    end
  end
  after :link_env, :create_database

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      within release_path do
        if test "[ -f #{fetch(:puma_pid)} ]" and test :kill, "-0 $( cat #{fetch(:puma_pid)} )"
          execute "echo $PATH"
          execute "which pumactl"
          execute "pumactl -S #{fetch(:puma_state)} restart"
        else
          execute "sudo service puma start"
        end
      end
    end

    on roles(:worker), in: :sequence, wait: 5 do
      within release_path do
        execute "sudo service sidekiq restart"
      end
    end
  end

  after :publishing, :restart

  desc "update ec2 tags"
  task :update_ec2_tags do
    on roles(:app) do
      within "#{release_path}" do
        branch = fetch(:branch)
        ref_type = fetch(:deploy_ref_type)
        last_commit = fetch(:current_revision)
        update_ec2_tags ref_type, branch, last_commit
      end
    end
  end
  after :restart, :update_ec2_tags
end
