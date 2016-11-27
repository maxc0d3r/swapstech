# First, we need to update our package list
apt_repository 'mongodb' do
  uri "http://downloads-distro.mongodb.org/repo/#{node[:mongodb][:apt_repo]}"
  distribution 'dist'
  components ['10gen']
  keyserver 'hkp://keyserver.ubuntu.com:80'
  key '7F0CEB10'
  action :add
end

execute 'apt-get-update' do
  command 'apt-get -y update'
end

# Install mongodb server
package 'mongodb-org' do
  action :install
  version node['mongo']['version']
end

directory '/data/mongo' do
  owner 'mongodb'
  group 'mongodb'
  mode '0755'
end

directory '/opt/mongodb' do
  owner 'mongodb'
  group 'mongodb'
  mode '0755'
end

cookbook_file '/opt/mongodb/keyfile' do
  source 'keyfile'
  owner 'mongodb'
  group 'mongodb'
  mode '0600'
end

is_journal_enabled = true
if node['mongo_instance_type'] == 'arbiter'
  is_journal_enabled = false
end

template '/etc/mongodb.conf' do
  source 'mongodb.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    :is_journal_enabled => is_journal_enabled,
    :replSetName => node['mongo']['replSetName']
  )
  notifies :restart, 'service[mongodb]', :delayed
end

service 'mongodb' do
  action [:enable, :start]
end
