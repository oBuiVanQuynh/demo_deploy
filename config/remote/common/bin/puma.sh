#!/bin/bash
# path : {rails_root}/config/remote/{env}/common/bin/puma.sh

APP_ROOT=/usr/local/rails_apps/demo_deploy/current
source ~/.bashrc
cd $APP_ROOT
/home/ec2-user/.rbenv/shims/puma -C $APP_ROOT/config/puma.rb
