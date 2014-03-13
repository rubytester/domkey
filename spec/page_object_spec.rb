require 'spec_helper'

# methods each pageobject should have
# set value options elements

describe Domkey::View::PageObject do

  before :all do
    Domkey.browser.goto("file://" + __dir__ + "/html/test.html")
  end

  context 'exceptions' do

    it 'bad proc for watirproc argument' do
      expect { Domkey::View::PageObject.new lambda { 'foo' } }.to raise_error(Domkey::Exception::Error)
    end

    it 'bad object for watirproc argument' do
      expect { Domkey::View::PageObject.new(Object.new) }.to raise_error(Domkey::Exception::Error)
    end
  end

  context 'when container is browser by default and' do

    it 'watirproc is watirproc' do
      watirproc = lambda { text_field(id: 'street1') }
      street    = Domkey::View::PageObject.new watirproc

      street.watirproc.should be_kind_of(Proc)
      street.element.should be_kind_of(Watir::TextField) #one default element

      # talk to browser
      street.set 'Lamar'
      street.value.should eql 'Lamar'
    end

    it 'watirproc is pageobject' do
      # setup
      watir_object = lambda { text_field(id: 'street1') }
      pageobject   = Domkey::View::PageObject.new watir_object

      # test
      street       = Domkey::View::PageObject.new pageobject

      street.watirproc.should be_kind_of(Proc)
      street.element.should be_kind_of(Watir::TextField)


      # talk to browser
      street.set 'zooom' #sending string here so no hash like in composed object
      street.value.should eql 'zooom'
    end

    it 'watirproc is proc hash where values are watirprocs' do
      hash      = {street1: lambda { text_field(id: 'street1') }, city: lambda { text_field(id: 'city1') }}
      watirproc = lambda { hash }
      address   = Domkey::View::PageObject.new watirproc

      address.watirproc.should respond_to(:each_pair)
      address.watirproc.each_pair do |k, v|
        k.should be_kind_of(Symbol)
        v.should be_kind_of(Domkey::View::PageObject) #should respond to set and value
      end

      address.element.should respond_to(:each_pair)
      address.element.each_pair do |k, v|
        v.should be_kind_of(Watir::TextField) #resolve suitecase
      end

    end

    it 'watirproc is hash where values are watirprocs' do

      hash = {street1: lambda { text_field(id: 'street1') }, city: lambda { text_field(id: 'city1') }}

      address = Domkey::View::PageObject.new hash

      address.watirproc.should respond_to(:each_pair)
      address.watirproc.each_pair do |k, v|
        k.should be_kind_of(Symbol)
        v.should be_kind_of(Domkey::View::PageObject) #should respond to set and value
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
      container = Domkey::View::PageObject.new Proc.new { div(:id, 'container') }, browser

      e    = lambda { text_field(class: 'city') }
      city = Domkey::View::PageObject.new e, container
      city.set 'Hellocontainer'

      #verify
      Domkey.browser.div(:id, 'container').text_field(:class, 'city').value.should == 'Hellocontainer'
    end
  end


end
