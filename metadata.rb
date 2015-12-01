name 'sysctl2'
maintainer 'Michael Morris'
maintainer_email 'michael.m.morris@gmail.com'
license '3-clause BSD'
description 'Installs/Configures sysctl kernel parameter settings'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.2.1'

%w(redhat centos fedora ubuntu debian).each do |p|
  supports p
end

attribute 'sysctl/conf_dir',
          display_name: 'Config Dir',
          description: 'The name of the directory containing the sysctl settings file',
          type: 'string',
          required: 'required',
          recipes:  ['sysctl::default'],
          default:  '/etc/sysctl.d'

attribute 'sysctl/conf_file',
          display_name: 'Config File',
          description: 'The name of the file containing the sysctl settings',
          type: 'string',
          required: 'required',
          recipes:  ['sysctl::default'],
          default:  '999-chef-sysctl.conf'
