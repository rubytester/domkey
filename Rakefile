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

namespace :docker do
  task :start do
    sh "docker run -d -p 5905:5900 -p 4444:4444 -v #{__dir__}:#{__dir__} -w #{__dir__} --name domkey_chrome rubytester/standalone-chrome-debug:41"
  end

  task :stop do
    sh "docker stop domkey_chrome && docker rm domkey_chrome"
  end
end