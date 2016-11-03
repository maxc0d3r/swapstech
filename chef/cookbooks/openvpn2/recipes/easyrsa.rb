vars = {
  "EASYRSA_PKI"         => "#{node['openvpn2']['key_dir']}/pki",
  "EASYRSA_DN"          => "cn_only",
  "EASYRSA_CERT_EXPIRE" => node['openvpn2']['authority']['defaults']['cert_expiry'],
  "EASYRSA_CRL_DAYS"    => node['openvpn2']['authority']['defaults']['crl_days'],
  "EASYRSA_DIGEST"      => node['openvpn2']['authority']['defaults']['digest'],
  "EASYRSA_KEY_SIZE"    => 2048,
  "EASYRSA_REQ_CN"      => node['openvpn2']['authority']['defaults']['root_domain'],
  "EASYRSA_REQ_COUNTRY" => node['openvpn2']['authority']['defaults']['country'],
  "EASYRSA_REQ_PROVINCE" => node['openvpn2']['authority']['defaults']['region'],
  "EASYRSA_REQ_CITY"    => node['openvpn2']['authority']['defaults']['city'],
  "EASYRSA_REQ_ORG"     => node['openvpn2']['authority']['defaults']['org'],
  "EASYRSA_REQ_OU"      => node['openvpn2']['authority']['defaults']['org_unit'],
  "EASYRSA_REQ_EMAIL"   => node['openvpn2']['authority']['defaults']['email']
}

remote_file "#{Chef::Config[:file_cache_path]}/EasyRSA-3.0.0-rc2.tgz" do
  source "https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.0-rc2/EasyRSA-3.0.0-rc2.tgz"
  notifies :run, 'execute[extract-easyrsa]', :immediately
end

execute 'extract-easyrsa' do
  cwd(Chef::Config[:file_cache_path])
  command "tar xf #{Chef::Config[:file_cache_path]}/EasyRSA-3.0.0-rc2.tgz"
  notifies :run, 'execute[install-easyrsa]', :immediately
  action :nothing
end

execute 'install-easyrsa' do
  command "cp #{Chef::Config[:file_cache_path]}/EasyRSA-3.0.0-rc2/easyrsa /usr/sbin"
  notifies :run, 'execute[copy-openssl-cfg]', :immediately
  action :nothing
end

execute 'copy-openssl-cfg' do
  command "cp #{Chef::Config[:file_cache_path]}/EasyRSA-3.0.0-rc2/openssl-1.0.cnf #{node['openvpn2']['key_dir']}"
  action :nothing
end

execute 'init-pki' do
  cwd(node['openvpn2']['key_dir'])
  command 'easyrsa init-pki'
  not_if { ::File.exists?("#{node['openvpn2']['key_dir']}/pki") }
end

build_ca_code = ""
vars.each { |k,v| build_ca_code += "#{k}='#{v}' " }
build_ca_code += "openssl req -batch -days 3650 -nodes -new -newkey rsa:2048 -sha1 -x509 -out #{node['openvpn2']['key_dir']}/pki/ca.crt -keyout #{node['openvpn2']['key_dir']}/pki/private/ca.key -config #{node['openvpn2']['key_dir']}/openssl-1.0.cnf"

file "/usr/sbin/openvpn-initca" do
  owner 'openvpn'
  group 'openvpn'
  mode '0755'
  content(build_ca_code)
end

execute "/usr/sbin/openvpn-initca"
