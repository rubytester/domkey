require 'domkey/version'
require 'watir-webdriver'
require 'domkey/view'
require 'domkey/view/page_object'
require 'domkey/view/page_object_collection'
require 'domkey/view/radio_group'
require 'domkey/view/checkbox_group'
require 'domkey/view/select_list'
require 'domkey/view/binder'
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
