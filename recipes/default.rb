#
# Cookbook Name:: sysctl2
# Recipe:: default
#
# Copyright 2014, Mike Morris
#

conf_file = ::File.join(node['sysctl']['conf_dir'], node['sysctl']['conf_file'])

sysctl_command = value_for_platform(
  %w(centos redhat debian) => {
    '< 7.0' => "sysctl -p #{conf_file}"
  },
  'ubuntu' => {
    '< 14.0' => "sysctl -p #{conf_file}"
  },
  'default' => 'sysctl --system'
)

execute 'update kernel params' do
  action :nothing
  command sysctl_command
  returns [0, 255]
end

template conf_file do
  source 'sysctl.conf.erb'
  cookbook 'sysctl2'
  owner 'root'
  group 'root'
  mode '0644'
  variables params: node['sysctl']['params']
  notifies :run, 'execute[update kernel params]'
end
