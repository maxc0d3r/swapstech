# First, we need to update our package list
execute 'apt-get-update' do
  command 'apt-get -y update'
end

# Install the latest openvpn server and easy-rsa
['openvpn','easy-rsa'].each do |pkg|
  package pkg
end

# Setup easy-rsa
execute 'copy-easy-rsa' do
  command 'cp -r /usr/share/easy-rsa/ /etc/openvpn'
  creates '/etc/openvpn/easy-rsa'
end

# Setup openvpn server config
template '/etc/openvpn/server.conf' do
  source 'openvpn-server.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    :port => node['openvpn']['port'],
    :protocol => node['openvpn']['protocol'],
    :server_ip_block => node['openvpn']['server']['ip_block'],
    :server_netmask => node['openvpn']['server']['netmask'],
    :route_ip_block => node['openvpn']['route']['ip_block'],
    :route_netmask => node['openvpn']['route']['netmask']
  )
end

# Setup easy-rsa vars
template '/etc/openvpn/easy-rsa/vars' do
  source 'easy-rsa-vars.erb'
  owner 'root'
  group 'root'
  mode '0755'
  variables(
    :key_country => node['openvpn']['key']['country'],
    :key_province => node['openvpn']['key']['province'],
    :key_city => node['openvpn']['key']['city'],
    :key_org => node['openvpn']['key']['org'],
    :key_email => node['openvpn']['key']['email'],
    :key_ou => node['openvpn']['key']['ou'],
  )
end

# Setup script to build ca keys
cookbook_file '/etc/openvpn/easy-rsa/build-ca' do
  source 'build-ca'
  owner 'root'
  group 'root'
  mode '0755'
end

# Setup script to build server keys
cookbook_file '/etc/openvpn/easy-rsa/build-key-server' do
  source 'build-key-server'
  owner 'root'
  group 'root'
  mode '0755'
end

# Setup script to build client keys
cookbook_file '/etc/openvpn/easy-rsa/build-key' do
  source 'build-key'
  owner 'root'
  group 'root'
  mode '0755'
end

# Setup script to build desired keys and certificates
cookbook_file '/usr/local/bin/setup-openvpn' do
  source 'setup-openvpn'
  owner 'root'
  group 'root'
  mode '0755'
end

# Setup directory to store keys
directory '/etc/openvpn/easy-rsa/keys' do
  owner 'root'
  group 'root'
  mode '0755'
end

# Setup openvpn
execute 'setup-openvpn' do
  command '/usr/local/bin/setup-openvpn'
  creates '/etc/openvpn/easy-rsa/openvpn-setup.txt'
end

# Enable openvpn service to startup on boot and also start the service
service 'openvpn' do
  action [:enable, :start]
end
