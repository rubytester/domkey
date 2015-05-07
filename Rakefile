require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/*_spec.rb'
end

desc "runs all the test in default local chrome. You must install chromedriver first"
task :default => :spec

desc "runs all tests in docker container. Assumes docker engine is up. On OSX use boot2docker"
task :docker => ["docker:spec"]

namespace :docker do

  task :spec => [:start, :set_env, :default, :stop]

  task :set_env do
    host                = %x(boot2docker ip)
    ENV['DOMKEY_DOCKER']="http://#{host.chomp}:4444/wd/hub"
  end

  desc "docker run standalone chrome debug"
  task :start do
    sh "docker run -d -p 5905:5900 -p 4444:4444 -v #{__dir__}:#{__dir__} -w #{__dir__} --name domkey_docker rubytester/standalone-chrome-debug:41"
  end

  desc "docker stop and rm"
  task :stop do
    sh "docker stop domkey_docker && docker rm domkey_docker"
  end

  desc "watch browser in vnc window osx"
  task :vnc do
    sh "open vnc://:secret@$(boot2docker ip):5905"
  end
end