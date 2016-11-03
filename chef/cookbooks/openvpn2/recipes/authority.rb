remote_file "#{Chef::Config[:file_cache_path]}/authority.zip" do
  source "http://dl.bintray.com/ovrclk/pkgs/authority_#{node['openvpn2']['authority']['version']}_linux_amd64.zip"
end

execute 'extract-authority' do
  command "unzip -o #{Chef::Config[:file_cache_path]}/authority.zip -d /usr/bin"
end

execute 'init-authority' do
  command "authority init #{node['openvpn2']['key_dir']}"
  not_if { ::File.exists?("#{node['openvpn2']['key_dir']}/.authority") }
end

template "#{node['openvpn2']['key_dir']}/.authority/config" do
  source "authority_config.erb"
  variables(:config => node['openvpn2']['authority'])
end
