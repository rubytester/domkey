require 'spec_helper'

# methods each pageobject should have
# set value options elements

describe Domkey::Page::PageObject do

  before :all do
    Domkey.browser.goto("file://" + __dir__ + "/html/test.html")
  end

  context 'when container is browser by default and' do

    before :all do
      @container = lambda { Domkey.browser }
    end

    it 'watirproc is watirproc' do
      watirproc = lambda { text_field(id: 'street1') }
      street    = Domkey::Page::PageObject.new watirproc, @container

      street.watirproc.should be_kind_of(Proc)
      street.element.should be_kind_of(Watir::TextField) #one default element

      # talk to browser
      street.set 'Lamar'
      street.value.should eql 'Lamar'
    end

    it 'watirproc is pageobject' do
      # setup
      watir_object = lambda { text_field(id: 'street1') }
      pageobject   = Domkey::Page::PageObject.new watir_object, @container

      # test
      street       = Domkey::Page::PageObject.new pageobject, @container

      street.watirproc.should be_kind_of(Proc)
      street.element.should be_kind_of(Watir::TextField)


      # talk to browser
      street.set 'zooom' #sending string here so no hash like in composed object
      street.value.should eql 'zooom'
    end

    it 'watirproc is proc hash where values are watirprocs' do
      hash      = {street1: lambda { text_field(id: 'street1') }, city: lambda { text_field(id: 'city1') }}
      watirproc = lambda { hash }
      address   = Domkey::Page::PageObject.new watirproc, @container

      address.watirproc.should respond_to(:each_pair)
      address.watirproc.each_pair do |k, v|
        k.should be_kind_of(Symbol)
        v.should be_kind_of(Domkey::Page::PageObject) #should respond to set and value
      end

      address.element.should respond_to(:each_pair)
      address.element.each_pair do |k, v|
        v.should be_kind_of(Watir::TextField) #resolve suitecase
      end

    end

    it 'watirproc is hash where values are watirprocs' do

      hash = {street1: lambda { text_field(id: 'street1') }, city: lambda { text_field(id: 'city1') }}

      address = Domkey::Page::PageObject.new hash, @container

      address.watirproc.should respond_to(:each_pair)
      address.watirproc.each_pair do |k, v|
        k.should be_kind_of(Symbol)
        v.should be_kind_of(Domkey::Page::PageObject) #should respond to set and value
      end

      address.element.should respond_to(:each_pair)
      address.element.each_pair do |k, v|
        v.should be_kind_of(Watir::TextField) #resolve suitecase
      end


      # talk to browser
      address.element[:street1].set 'helloworld'
      address.element[:street1].value.should eql 'helloworld'

      # pageobject.set value
      # sends values to each element.set value
      value = {city: 'Berlin', street1: 'Fredrichstrasse'}
      address.set value

      ## pageobject.value => returns value from the page
      # asks each element for its value and aggregates value for entire pageobject
      expected_value = address.value

      # compare to value we sent earlier
      expected_value.should eql(value)

      # element by element
      address.element(:city).value.should eql 'Berlin'
      address.element(:city).set 'Austin'
      address.element(:city).value.should eql 'Austin'

    end
  end

  context 'when container is pageobject' do

    it 'pageobject.dom becomes container' do
      browser   = lambda { Domkey.browser }
      container = Domkey::Page::PageObject.new Proc.new { div(:id, 'container') }, browser

      e    = lambda { text_field(class: 'city') }
      city = Domkey::Page::PageObject.new e, container
      city.set 'Hellocontainer'

      #verify
      Domkey.browser.div(:id, 'container').text_field(:class, 'city').value.should == 'Hellocontainer'
    end
  end


end
