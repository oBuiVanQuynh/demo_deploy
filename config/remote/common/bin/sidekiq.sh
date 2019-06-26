#!/bin/bash
# path : {rails_root}/config/remote/{env}/common/bin/sidekiq.sh

APP_ROOT=/usr/local/rails_apps/demo_deploy/current
source ~/.bashrc
cd $APP_ROOT
/home/ec2-user/.rbenv/shims/bundle exec sidekiq -C config/sidekiq.yml -e $RAILS_ENV
