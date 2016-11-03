include_recipe('openvpn2::package')

# create openvpn user and group
user(node['openvpn2']['user'])
group(node['openvpn2']['user']) do
  members(node['openvpn2']['user'])
end

directory(node['openvpn2']['key_dir']) do
  action :create
end

# generate server keys
case node['openvpn2']['provisioner']
when 'authority'
  include_recipe('openvpn2::authority')
  execute 'create-server-keys' do
    cwd(node['openvpn2']['key_dir'])
    command 'authority generate server'
    not_if { ::File.exist?("#{node['openvpn2']['key_dir']}/certs/server.crt") }
  end
when 'easyrsa'
  include_recipe('openvpn2::easyrsa')
  # execute 'create-server-keys' do
  #   cwd(node['openvpn2']['key_dir'])
  #   command 'authority generate server'
  #   not_if { ::File.exist?("#{node['openvpn2']['key_dir']}/certs/server.crt") }
  # end
end

# generate dhparams
execute 'create-dhparams' do
  command "openssl dhparam 1024 -out #{node['openvpn2']['key_dir']}/dh.pem"
  not_if { ::File.exists?("#{node['openvpn2']['key_dir']}/dh.pem") }
end 

template '/etc/openvpn/server.up.sh' do
  source 'server.up.sh.erb'
  owner 'root'
  group 'root'
  mode  '0755'
  notifies :restart, 'service[openvpn]'
end

openvpn2_config 'server' do
  notifies :restart, 'service[openvpn]'
  action :create
end

service 'openvpn' do
  action [:enable, :start]
end
