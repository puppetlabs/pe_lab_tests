# !/usr/bin/env ruby
# frozen_string_literal: true

# Copyright 2025. Puppet, Inc., a Perforce company.  

class PuppetCert  

  CERT_DIR = "/etc/puppetlabs/puppet/ssl/certs/"

  @certificate = nil; # OpenSSL::X509::Certificate

  def initialize
    raise "Directory #{CERT_DIR} does not exist" unless Dir.exist?(CERT_DIR)
    @filename = get_filename  
    raise "Certificate file #{@filename} does not exist" unless File.exist?(@filename)
    raise "Certificate file #{@filename} is not readable" unless File.readable?(@filename)
    raise "Certificate file #{@filename} is empty" unless File.size?(@filename) > 0
    @certificate = OpenSSL::X509::Certificate.new(File.read(@filename))
  end

  def get_filename
    hostname = `hostname -f`.strip.downcase
    return CERT_DIR + "#{hostname}.pem"
  end

  def get_certificate
    return @certificate
  end

  def is_valid?
    return @certificate.not_before < Time.now && @certificate.not_after > Time.now
  end
end
