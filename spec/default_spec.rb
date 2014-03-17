require 'spec_helper'

platforms = [
  { 'centos' => '5.9' },
  { 'centos' => '6.3' },
  { 'centos' => '6.4' },
  { 'centos' => '6.5' },
  { 'redhat' => '5.9' },
  { 'redhat' => '5.10' },
  { 'redhat' => '6.3' },
  { 'redhat' => '6.4' },
  { 'redhat' => '6.5' },
  { 'fedora' => '18' },
  { 'fedora' => '19' },
  { 'fedora' => '20' },
  { 'ubuntu' => '12.04' },
  { 'ubuntu' => '13.04' },
  { 'debian' => '7.2' },
  { 'debian' => '7.4' }
]

platforms.each { |i| i.each_pair do |p,v|
  describe 'sysctl2::default' do
    let (:chef_run) { ChefSpec::Runner.new(platform:p, version:v, :log_level => :info) do |node|
      Chef::Log.debug(sprintf("#### FILE: %s  PLATFORM: %s  VERSION: %s ####", ::File.basename(__FILE__), p, v))

      env = Chef::Environment.new
      env.name 'testing'
      # Stub the node to return this environment
      node.stub(:chef_environment).and_return env.name

      if node.platform_family?('rhel')
      then
        node.set['sysctl']['conf_dir']  = '/etc'
        node.set['sysctl']['conf_file'] = 'sysctl.conf'
      end

      node.set['sysctl']['params']['kernel.sysrq'] = 1
      node.set['sysctl']['params']['kernel.core_uses_pid'] = 1
      node.set['sysctl']['params']['net.ipv4.ip_forward'] = 0
      node.set['sysctl']['params']['net.ipv4.ip_local_port_range'] = '30000 65000'
      node.set['sysctl']['params']['fs.aio-max-nr'] = 1048576

      # Stub any calls to Environment.load to return this environment
      Chef::Environment.stub(:load).and_return env

      Chef::Config[:solo] = true
    end.converge described_recipe}

    it 'creates the config file with approprate contents' do
      file = _get_sysctl_file(chef_run.node.platform_family?('rhel'))

      expect(chef_run).to create_template(file)
        .with(
          owner: 'root',
          group: 'root',
          mode:  '0644'
        )

      expect(chef_run).to render_file(file).with_content(/kernel.sysrq\s*=\s*1/)
      expect(chef_run).to render_file(file).with_content(/kernel.core_uses_pid\s*=\s*1/)
      expect(chef_run).to render_file(file).with_content(/net.ipv4.ip_forward\s*=\s*0/)
      expect(chef_run).to render_file(file).with_content(/net.ipv4.ip_local_port_range\s*=\s*30000 65000/)
      expect(chef_run).to render_file(file).with_content(/fs.aio-max-nr\s*=\s*1048576/)

      expect(chef_run.template(file)).to notify("execute[update kernel params]").to(:run)
    end

    it 'does not run sysctl until triggered' do
      expect(chef_run).to_not run_execute("update kernel params")
    end
  end
end }

def _get_sysctl_file(is_rhelish)
  file = '/etc/sysctl.d/999-chef-sysctl.conf'

  if is_rhelish
  then
    file = '/etc/sysctl.conf'
  end

  return file
end
