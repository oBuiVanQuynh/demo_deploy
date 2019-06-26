if ENV["LOCAL_DEPLOY"]
  server "localhost", user: "ec2-user", roles: %w(app db)
else
  instances = fetch(:instances)

  instances.each do |role_name, hosts|
    roles = [role_name]
    hosts.each_with_index do |host, i|
      roles << "db" if i == 0
      server host, user: "ec2-user", roles: roles
    end
  end
end
