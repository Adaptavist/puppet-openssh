require "#{File.join(File.dirname(__FILE__),'..','spec_helper.rb')}"

describe 'openssh' do

  let(:title) { 'openssh' }
  let(:node) { 'rspec.example42.com' }
  let(:facts) { { :ipaddress => '10.42.42.42' } }

  describe 'Test standard installation' do
    let(:params) { { } }

    it { should contain_package('openssh').with_ensure('present') }
    it { should contain_service('openssh').with_ensure('running') }
    it { should contain_service('openssh').with_enable('true') }
    it { should contain_file('openssh.conf').with_ensure('present') }
  end

  describe 'Test decommissioning - absent' do
    let(:params) { {:absent => true} }

    it { should contain_package('openssh').with_ensure('absent') }
    it { should contain_service('openssh').with_ensure('stopped') }
    it { should contain_service('openssh').with_enable('false') }
    it { should contain_file('openssh.conf').with_ensure('absent') }
  end

  describe 'Test decommissioning - disable' do
    let(:params) { {:disable => true} }

    it { should contain_package('openssh').with_ensure('present') }
    it { should contain_service('openssh').with_ensure('stopped') }
    it { should contain_service('openssh').with_enable('false') }
    it { should contain_file('openssh.conf').with_ensure('present') }
  end

  describe 'Test decommissioning - disableboot' do
    let(:params) { {:disableboot => true} }
  
    it { should contain_package('openssh').with_ensure('present') }
    it { should_not contain_service('openssh').with_ensure('present') }
    it { should_not contain_service('openssh').with_ensure('absent') }
    it { should contain_service('openssh').with_enable('false') }
    it { should contain_file('openssh.conf').with_ensure('present') }
  end 

  describe 'Test customizations - template' do
    let(:params) { {:template => "openssh/spec.erb" , :options => { 'opt_a' => 'value_a' } } }

    it 'should generate a valid template' do
      content = catalogue.resource('file', 'openssh.conf').send(:parameters)[:content]
      content.should match "fqdn: rspec.example42.com"
    end
    it 'should generate a template that uses custom options' do
      content = catalogue.resource('file', 'openssh.conf').send(:parameters)[:content]
      content.should match "value_a"
    end

  end

  describe 'Test customizations - source' do
    let(:params) { {:source => "puppet://modules/openssh/spec" , :source_dir => "puppet://modules/openssh/dir/spec" , :source_dir_purge => true } }

    it 'should request a valid source ' do
      content = catalogue.resource('file', 'openssh.conf').send(:parameters)[:source]
      content.should == "puppet://modules/openssh/spec"
    end
    it 'should request a valid source dir' do
      content = catalogue.resource('file', 'openssh.dir').send(:parameters)[:source]
      content.should == "puppet://modules/openssh/dir/spec"
    end
    it 'should purge source dir if source_dir_purge is true' do
      content = catalogue.resource('file', 'openssh.dir').send(:parameters)[:purge]
      content.should == true
    end
  end

  describe 'Test customizations - custom class' do
    let(:params) { {:my_class => "openssh::spec" } }
    it 'should automatically include a custom class' do
      content = catalogue.resource('file', 'openssh.conf').send(:parameters)[:content]
      content.should match "fqdn: rspec.example42.com"
    end
  end

  describe 'Test Puppi Integration' do
    let(:params) { {:puppi => true, :puppi_helper => "myhelper"} }

    it { should contain_file('puppi_openssh').with_ensure('present') }
    it 'should generate a valid puppi data file' do
      content = catalogue.resource('file', 'puppi_openssh').send(:parameters)[:content]
      expected_lines = [ '  puppi_helper: myhelper' , '  puppi: true' ]
      (content.split("\n") & expected_lines).should == expected_lines
    end
  end

  describe 'Test Monitoring Integration' do
    let(:params) { {:monitor => true, :monitor_tool => "puppi" } }

    it 'should generate monitor defines' do
      content = catalogue.resource('monitor::process', 'openssh_process').send(:parameters)[:tool]
      content.should == "puppi"
    end
  end

  describe 'Test Firewall Integration' do
    let(:params) { {:firewall => true, :firewall_tool => "iptables" , :protocol => "tcp" , :port => "42" } }

    it 'should generate correct firewall define' do
      content = catalogue.resource('firewall', 'openssh_tcp_42').send(:parameters)[:tool]
      content.should == "iptables"
    end
  end
end

