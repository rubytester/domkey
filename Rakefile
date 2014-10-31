require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/*_spec.rb'
end

task :default => :spec

# kill browsers dude
task :pkill do
  `pkill -f firefox`
end