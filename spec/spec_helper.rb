$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rspec'
require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
end
require 'domkey'
SimpleCov.command_name "test:units"

module DomkeySpecHelper

  def goto_watirspec file
    goto("file://" + __dir__ + "/watirspec/html/#{file}")
  end

  def goto_html file
    goto("file://" + __dir__ + "/html/#{file}")
  end

  def goto path
    Domkey.browser.goto path
  end

end

RSpec.configure do |config|
  config.include DomkeySpecHelper
  config.after :all do
    Domkey.browser.close
  end
end