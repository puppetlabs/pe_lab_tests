# Copyright 2025. Puppet, Inc., a Perforce company.  

require 'spec_helper'

describe 'Development Environment node' do

  describe package('code') do
    it { should be_installed }
  end

  describe package('pdk') do
    it { should be_installed }
  end

  describe package('xrdp') do
    it { should be_installed }
  end

  describe service('xrdp') do
    it { should be_enabled }
    it { should be_running }
  end

  describe file('/etc/xrdp/xrdp.ini') do
    it { should be_file }
  end

  describe 'git' do
    it 'is installed' do
    end
  end
end