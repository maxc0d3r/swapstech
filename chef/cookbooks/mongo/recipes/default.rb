# First, we need to update our package list
apt_repository 'mongodb' do
  uri "http://repo.mongodb.org/apt/ubuntu"
  distribution 'xenial/mongodb-org/3.2'
  components ['multiverse']
  keyserver 'hkp://keyserver.ubuntu.com:80'
  key '7F0CEB10'
  action :add
end

execute 'apt-get-update' do
  command 'apt-get -y update'
end

# Install mongodb server
package 'mongodb-org' do
  options '-o Dpkg::Options::="--force-confold" --force-yes'
  version node['mongo']['version']
  action :install
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

template '/etc/init/mongodb.conf' do
  source 'mongo_upstart.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    :ulimit => node['mongo']['ulimit']
    :provides => 'mongod'
    :sysconfig_file => '/etc/default/mongodb'
  )
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
  notifies :restart, 'service[mongod]', :delayed
end

service 'mongod' do
  action [:enable, :start]
end
