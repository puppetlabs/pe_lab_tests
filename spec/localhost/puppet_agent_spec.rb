# Copyright 2025. Puppet, Inc., a Perforce company.  

require 'spec_helper'

describe 'Puppet Agent node' do

  describe package('puppet-agent') do
    it { should be_installed }
  end

  describe service('puppet') do
    it { should be_enabled }
    it { should be_running }
  end

  describe 'Puppet Agent certificate' do
    let(:puppet_cert) { PuppetCert.new }

    it 'is valid' do
      expect(puppet_cert.get_certificate.is_valid?).to be true
    end
  end
end