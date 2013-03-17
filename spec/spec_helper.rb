require "bundler/setup"
require "db"
require File.join "db", "rails"
require File.join "db", "pg"
require File.join "db", "cli"
require "pry"

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end
