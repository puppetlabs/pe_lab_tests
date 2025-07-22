# Copyright 2025. Puppet, Inc., a Perforce company.  

require 'spec_helper'

describe 'Puppet Server node' do

  describe package('puppetserver') do
    it { should be_installed }
  end

  describe service('puppetserver') do
    it { should be_enabled }
    it { should be_running }
  end
end