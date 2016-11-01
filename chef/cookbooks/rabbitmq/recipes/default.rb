# First, we need to update our package list
execute 'apt-get-update' do
  command 'apt-get -y update'
end

# Install the latest rabbitmq server version
package 'rabbitmq-server'

bash 'setup_autocluster' do
  cwd "/tmp"
  code <<-EOH
    wget https://github.com/aweber/rabbitmq-autocluster/releases/download/#{node['autocluster']['version']}/autocluster-#{node['autocluster']['version']}.tgz
    tar -zxf autocluster-#{node['autocluster']['version']}.tgz
    cp -r plugins /usr/lib/rabbitmq/lib/rabbitmq_server-*/
  EOH
end

execute 'enable_rabbitmq_plugins' do
  command 'rabbitmq-plugins enable autocluster'
end

cookbook_file '/var/lib/rabbitmq/.erlang.cookie' do
  source 'erlang.cookie'
  owner 'rabbitmq'
  group 'rabbitmq'
  mode '0400'
end

cookbook_file '/etc/rabbitmq/rabbitmq.config' do
  source 'rabbitmq.config'
  owner 'root'
  group 'root'
  mode '0644'
end

cookbook_file '/etc/rabbitmq/rabbitmq-env.conf' do
  source 'rabbitmq-env.conf'
  owner 'root'
  group 'root'
  mode '0644'
end

service 'rabbitmq-server' do
  action [:enable, :restart]
end
