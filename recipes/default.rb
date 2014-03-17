#
# Cookbook Name:: sysctl
# Recipe:: default
#
# Copyright 2014, Mike Morris
#

conf_file = ::File.join(node['sysctl']['conf_dir'], node['sysctl']['conf_file'])

execute "update kernel params" do
  action :nothing
  command "sysctl -p #{conf_file}"
  returns [0, 255]
end

template conf_file do
  source 'sysctl.conf.erb'
  cookbook 'sysctl'
  owner 'root'
  group 'root'
  mode  '0644'
  variables :params => node['sysctl']['params']
  notifies :run, "execute[update kernel params]"
end
