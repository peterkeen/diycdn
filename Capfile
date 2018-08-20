require 'rubygems'
require 'capistrano-buildpack'

set :normalize_asset_timestamps, false
set :application, "cdn"
set :repository, "git@git.zrail.net:peter/diycdn.git"
set :scm, :git
set :additional_domains, ['cdn.zrail.net']
set :use_sudo, true

role :web, "kodos.zrail.net"
set :buildpack_url, "git@git.zrail.net:peter/bugsplat-buildpack-ruby-shared"

set :user,        "peter"
set :concurrency, "web=1,worker=1"
set :base_port,   7700
set :use_ssl, true
set :force_ssl, false
set :listen_address, '10.248.9.84'
set :foreman_export_path, "/lib/systemd/system"
set :foreman_export_type, "systemd"

read_env 'prod'

load 'deploy'
