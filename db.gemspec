# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "db/version"

Gem::Specification.new do |s|
  s.name        = "db"
  s.version     = DB::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Brooke Kuhlmann"]
  s.email       = ["brooke@redalchemist.com"]
  s.homepage    = "http://www.redalchemist.com"
  s.summary     = "Database management for the command line."
  s.description = "Database management for the command line with customizable options for common tasks."

  s.rdoc_options << "CHANGELOG.rdoc"
  s.add_dependency "thor"
  s.add_development_dependency "rspec"
  s.add_development_dependency "aruba"
  s.executables << "db"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map {|f| File.basename f}
  s.require_paths = ["lib"]
end
