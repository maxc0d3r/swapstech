case node['platform']
when 'amazon', 'centos', 'fedora', 'redhat'
  include_recipe 'yum-epel' if %w(centos redhat).include?(node['platform'])
when 'debian', 'ubuntu'
  include_recipe 'apt'
else
  fail "The package installation method for `#{node['platform']} is not supported.`"
end

%w(unzip openvpn).each do |pkg|
  package(pkg) do
    action :install
  end
end
