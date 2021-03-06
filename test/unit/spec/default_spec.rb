require_relative 'spec_helper'

platforms = [
  { 'centos' => '6.5' },
  { 'centos' => '7.0' },
  { 'redhat' => '6.5' },
  { 'redhat' => '7.0' },
  { 'fedora' => '19' },
  { 'fedora' => '20' },
  { 'fedora' => '21' },
  { 'ubuntu' => '12.04' },
  { 'ubuntu' => '13.10' },
  { 'ubuntu' => '14.04' },
  { 'debian' => '7.4' },
  { 'debian' => '8.0' }
]

platforms.each do |i|
  i.each_pair do |p, v|
    describe 'sysctl2::default' do
      let :chef_run do
        ChefSpec::SoloRunner.new(platform: p, version: v, log_level: :error) do |node|
          Chef::Log.debug(format('#### FILE: %s  PLATFORM: %s  VERSION: %s ####', ::File.basename(__FILE__), p, v))

          env = Chef::Environment.new
          env.name 'testing'
          # Stub the node to return this environment
          node.stub(:chef_environment).and_return env.name

          if node.platform_family?('rhel')
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
        end.converge described_recipe
      end

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

        expect(chef_run.template(file)).to notify('execute[update kernel params]').to(:run)
      end

      it 'does not update kernel params until triggered' do
        expect(chef_run).to_not run_execute('update kernel params')

        execute = chef_run.execute('update kernel params')
        expect(execute).to do_nothing
      end
    end
  end
end

def _get_sysctl_file(is_rhelish)
  file = '/etc/sysctl.d/999-chef-sysctl.conf'
  file = '/etc/sysctl.conf' if is_rhelish

  file
end
