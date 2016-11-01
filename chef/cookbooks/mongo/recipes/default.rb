# First, we need to update our package list
execute 'apt-get-update' do
  command 'apt-get -y update'
end

# Install mongodb server
package 'mongodb' do
  action :install
  version node['mongo']['version']
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
    :is_journal_enabled => is_journal_enabled
  )
end

service 'mongodb' do
  action [:enable, :restart]
end
