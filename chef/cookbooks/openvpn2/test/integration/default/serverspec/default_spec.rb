require 'spec_helper'

describe 'openvpn2::default' do

  describe package('openvpn') do
    it { should be_installed }
  end

  describe user('openvpn') do
    it { should exist }
  end

  describe user('openvpn') do
    it { should belong_to_group('openvpn') }
  end
end
