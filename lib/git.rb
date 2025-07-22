# !/usr/bin/env ruby
# frozen_string_literal: true

# Copyright 2025. Puppet, Inc., a Perforce company.  

class Git
  def self.installed?
    result = `git --version`
    return !result.nil? && !result.empty? && result.include?('git version')
  rescue StandardError => e
    return false
  end
end