require "bundler/setup"
require "db"
require "db/rails"
require "db/pg"
require "db/cli"
require "pry"

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run focus: true
end
