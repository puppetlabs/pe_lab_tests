# frozen_string_literal: true

require "pe_server_tests"
require "serverspec"

set :backend, :exec

$:.unshift File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))

require_relative "../lib/puppet_cert"
require_relative "../lib/git"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.expose_dsl_globally = true
end
