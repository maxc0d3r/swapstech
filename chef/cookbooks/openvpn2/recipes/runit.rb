include_recipe 'runit'

runit_service 'openvpn' do
  default_logger true
end
