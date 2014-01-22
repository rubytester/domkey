require 'domkey/version'
require 'watir-webdriver'
require 'domkey/browser_session'

module Domkey

  # current browser for testing session
  def self.browser
    BrowserSession.instance.browser
  end

  # sets current browser for testing session
  def self.browser=(b)
    BrowserSession.instance.browser=b
  end
end
