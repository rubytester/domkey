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


module Domkey

  # close browser on exit to cleanup after yourself
  def self.close_browser_on_exit
    return if @_close_browser_on_exit
    at_exit {
      if @browser && @browser.exists?
        @browser.close
      end
    }
    @_close_browser_on_exit = true
  end
end

Domkey.close_browser_on_exit

RSpec.configure do |config|
  config.include DomkeySpecHelper
end