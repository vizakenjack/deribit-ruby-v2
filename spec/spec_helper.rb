require "bundler/setup"
require "deribit"
require "pry"
require "vcr"

ENV["DERIBIT_SERVER"] = "test"

VCR.configure do |c|
  c.cassette_library_dir = "spec/cassettes"
  c.hook_into :webmock
  c.configure_rspec_metadata!
end

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.filter_run_when_matching :focus
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
