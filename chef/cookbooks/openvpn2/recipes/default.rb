#
# Cookbook Name:: openvpn2
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

include_recipe('openvpn2::server')
include_recipe('openvpn2::users')
