$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rspec'
require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
end
require 'domkey'
SimpleCov.command_name "test:units"

RSpec.configure do |config|
  config.after :all do
    Domkey.browser.close
  end
end