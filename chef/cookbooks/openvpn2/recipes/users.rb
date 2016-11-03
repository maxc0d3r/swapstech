def solo_search_installed?
  klass = ::Search.const_get('Helper')
  return klass.is_a?(Class)
rescue NameError
  return false
end

if node['openvpn2']['gateway'] == nil && node['openvpn2']['gateways'].size == 0
  Chef::Log.fatal("Either node['openvpn2']['gateway'] or node['openvpn2']['gateways'] should be set to generate client configuration.")
end

if Chef::Config[:solo] && !solo_search_installed?
  Chef::Log.fatal('Install chef-solo-search cookbook to create users')
else
  search(node['openvpn2']['users_databag'], node['openvpn2']['databag_search_query']) do |u|
    execute "generate-vpn-user-key-#{u['id']}" do
      cwd node['openvpn2']['key_dir']
      command "authority generate #{u['id']}"
      not_if { ::File.exists?("#{node['openvpn2']['key_dir']}/keys/#{u['id']}.key") }
    end

    directory "#{node['openvpn2']['key_dir']}/#{u['id']}" do
      recursive true
    end

    %w(conf ovpn).each do |ext|
      template "#{node['openvpn2']['key_dir']}/#{u['id']}/#{u['id']}.#{ext}" do
        source 'client.conf.erb'
        variables({:user => u['id']})
      end
    end

    execute "archive-config-#{u['id']}" do
      cwd node['openvpn2']['key_dir']
      command <<-CODE
  cp certs/ca.crt certs/#{u['id']}.crt keys/#{u['id']}.key #{u['id']}
  cd #{u['id']}
  tar czf #{u['id']}.tgz * && mv #{u['id']}.tgz ..
  CODE
    end
  end
end
