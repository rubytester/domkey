require 'domkey/version'
require 'domkey/browser'
require 'domkey/view'
require 'domkey/view/component'
require 'domkey/view/component_collection'
require 'domkey/view/radio_group'
require 'domkey/view/checkbox_group'
require 'domkey/view/select_list'
require 'domkey/view/binder'
require 'domkey/exception'

module Domkey

  # current browser for testing session
  def self.browser
    return @browser if (@browser && @browser.exist?)
    @browser = Browser.new
  end

  # sets current browser for testing session
  def self.browser=(b)
    @browser = b
  end

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
