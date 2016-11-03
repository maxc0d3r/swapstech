#
# Cookbook Name:: openvpn2-test
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

ip = `curl http://169.254.169.254/latest/meta-data/public-ipv4`

include_recipe('aws')

node.set['openvpn2']['gateway'] = ip

# aws_elastic_ip 'vpn_ip' do
#   ip node['eip']
#   aws_access_key node['aws_access_key_id']
#   aws_secret_access_key node['aws_secret_access_key']
# end

include_recipe('openvpn2::default')

# open permissions for testing
directory(node['openvpn2']['key_dir']) do
  recursive true
  mode 777
end

cookbook_file 'secret.key' do
  path '/etc/openvpn/secret.key'
end

openvpn2_config('tunnel-to-virginia') do
  config({
    :port => '1195',
    :dev => 'tun',
    :route => node['routes'],
    :ifconfig => "169.254.255.2 169.254.255.1",
    :secret => "secret.key"
  })
end

openvpn2_config('tunnel-to-california') do
  config({
    :port => '1195',
    :dev => 'tun',
    :route => node['routes'],
    :ifconfig => "169.254.255.1 169.254.255.2",
    :secret => "secret.key"
  })
end
