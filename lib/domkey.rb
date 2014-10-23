require 'domkey/version'
require 'watir-webdriver'
require 'domkey/view'
require 'domkey/exception'

module Domkey

  # current browser for testing session
  def self.browser
    return @browser if (@browser && @browser.exist?)
    # simple browser
    @browser = Watir::Browser.new
  end

  # sets current browser for testing session
  def self.browser=(b)
    @browser = browser
  end
end
