require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

# kill browsers dude
task :pkill do
  `pkill -f firefox`
end