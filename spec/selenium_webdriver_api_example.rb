require 'spec_helper'

# Watir API is the Bee's Knees
# but you can use lower level Selenium::WebDriver API for container and package definitions
# you will need to override set and value methods to delegate to Selenium::WebDriver::Element

describe 'Selenium::WebDriver API Example' do

  before :all do
    Domkey.browser.goto("file://" + __dir__ + "/../html/test.html")
    @driverpackage = -> { Domkey.browser.driver }
  end

  context 'when container is selenium webdriver and' do

    it 'package is package' do
      package = lambda { find_element(id: 'street1') }
      street  = Domkey::View::PageObject.new package, @driverpackage

      street.package.should be_kind_of(Proc)
      street.element.should be_kind_of(Selenium::WebDriver::Element) #one default element

      street.element.send_keys 'Lamar'
      street.element.attribute('value').should eql 'Lamar'
    end

    it 'package is pageobject' do
      # setup
      webdriver_element = lambda { find_element(id: 'street1') }

      pageobject = Domkey::View::PageObject.new webdriver_element, @driverpackage
      street     = Domkey::View::PageObject.new pageobject, @driverpackage

      street.package.should be_kind_of(Proc)
      street.element.should be_kind_of(Selenium::WebDriver::Element)

      street.element.clear
      street.element.send_keys 'zooom'
      street.element.attribute('value').should eql 'zooom'
    end
  end
end