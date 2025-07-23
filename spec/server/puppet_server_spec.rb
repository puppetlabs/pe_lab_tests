# Copyright 2025. Puppet, Inc., a Perforce company.  

require 'spec_helper'

describe 'Puppet Server node' do

  describe package('pe-puppetserver') do
    it { should be_installed }
  end

  describe service('pe-puppetserver') do
    it { should be_enabled }
    it { should be_running }
  end

  describe service('puppet') do
    it { should be_enabled }
    it { should be_running }
  end

  describe service('pe-puppetdb') do
    it { should be_enabled }
    it { should be_running }
  end

  describe service('pe-console-services') do
    it { should be_enabled }
    it { should be_running }
  end
end