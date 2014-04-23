require 'spec_helper'

describe file '/etc/sysctl.d/999-chef-sysctl.conf' do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  it { should_not be_writable.by('others') }

  its(:content) { should match(/kernel.sysrq\s*=\s*0/) }
  its(:content) { should match(/kernel.shmall\s*=\s*1073741824/) }
  its(:content) { should match(/kernel.shmmax\s*=\s*1073741824/) }
  its(:content) { should match(/kernel.shmmni\s*=\s*4096/) }
  its(:content) { should match(/net.ipv4.ip_forward\s*=\s*0/) }
  its(:content) { should match(/net.ipv4.ip_local_port_range\s*=\s*30000\s+65000/) }
end

describe 'Actual kernel parameter values' do
  context linux_kernel_parameter 'kernel.sysrq' do
    its(:value) { should eq 0 }
  end

  context linux_kernel_parameter 'kernel.shmall' do
    its(:value) { should eq 1073741824 }
  end

  context linux_kernel_parameter 'kernel.shmmax' do
    its(:value) { should eq 1073741824 }
  end

  context linux_kernel_parameter 'kernel.shmmni' do
    its(:value) { should eq 4096 }
  end

  context linux_kernel_parameter 'net.ipv4.ip_forward' do
    its(:value) { should eq 0 }
  end

  context linux_kernel_parameter 'net.ipv4.ip_local_port_range' do
    its(:value) { should match(/30000\s+65000/) }
  end
end
