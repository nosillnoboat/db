require "gemsmith/rake/setup"
Dir.glob("lib/db/tasks/*.rake").each { |file| load file }

task default: %w(spec rubocop)
