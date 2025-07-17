# Copyright 2025. Puppet, Inc., a Perforce company.  

require 'spec_helper'

describe package('puppet-agent') do
  it { should be_installed }
end

describe service('puppet') do
  it { should be_enabled }
  it { should be_running }
end