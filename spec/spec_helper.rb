$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rspec'
require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
end
require 'domkey'
SimpleCov.command_name "test:units"

module DomkeySpecHelper

  def goto_html file
    goto("file://" + __dir__ + "/html/#{file}")
  end

  def goto path
    Domkey.browser.goto path
  end

end


Domkey.close_browser_on_exit

Domkey::Browser.factory do
  Watir::Browser.new :chrome #local binary
end


RSpec.configure do |config|
  config.include DomkeySpecHelper
end