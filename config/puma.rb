threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count

preload_app!

root_dir = Dir.pwd

# Specifies the `environment` that Puma will run in.
#
environment ENV.fetch("RAILS_ENV") { "#{ENV['RAILS_ENV']}" }

daemonize false

pidfile File.join(root_dir, "tmp", "pids", "puma.pid")

state_path File.join(root_dir, "tmp", "pids", "puma.state")

# bind "tcp://0.0.0.0:3000"
shared_dir = root_dir.gsub(/releases\/\d{14}/,"shared")
bind "unix://#{shared_dir}/tmp/sockets/puma.sock"
