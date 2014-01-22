require 'domkey/version'
require 'watir-webdriver'
require 'domkey/browser_session'
require 'domkey/page_object'

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
