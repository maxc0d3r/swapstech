use_inline_resources if defined?(use_inline_resources)

action :create do
  template "/etc/openvpn/#{new_resource.name}.conf" do
    cookbook  'openvpn2'
    source    'server.conf.erb'
    owner     'root'
    group     'root'
    mode      0644
    variables :config => (new_resource.config || node['openvpn2']['config'])
  end
end

action :delete do
  file "/etc/openvpn/#{new_resource.name}.conf" do
    action :delete
  end
end
