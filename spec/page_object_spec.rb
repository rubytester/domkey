require 'spec_helper'

# methods each pageobject should have
# set value options elements

describe Domkey::PageObject do

  before :all do
    Domkey.browser.goto("file://" + __dir__ + "/html/test.html")
  end

  after :all do
    Domkey.browser.quit
  end

  context 'single element definition' do

    context 'container is browser' do

      before :all do
        @container = lambda { Domkey.browser }
      end

      #context 'does not respond to errors' do
      #
      #  it 'set' do
      #    container = lambda { Domkey.browser }
      #    watirproc = lambda { 'hello world' }
      #    po        = Domkey::PageObject.new watirproc, container
      #    po.set 'hello'
      #  end
      #
      #  it 'value'
      #  it 'options'
      #  it 'element'
      #end


      it 'watirproc' do
        watirproc = lambda { text_field(id: 'street1') }
        street    = Domkey::PageObject.new watirproc, @container

        street.set 'Lamar'
        street.value.should eql 'Lamar'
        street.element.should be_kind_of(Watir::TextField) #one default element
      end

      it 'pageobject' do
        watir_object             = lambda { text_field(id: 'street1') }
        street_from_watir_object = Domkey::PageObject.new watir_object, @container
        street                   = Domkey::PageObject.new street_from_watir_object, @container

        street.set 'zooom' #sending string here so no hash like in composed object
        street.value.should eql 'zooom'
        street.element.should be_kind_of(Watir::TextField)
      end
    end

  end

  context 'collection of elements definition' do

    context 'container is browser' do

      before :all do
        @container = lambda { Domkey.browser }
      end

      it 'watirproc only' do
        elements = {street1: lambda { text_field(id: 'street1') }, city: lambda { text_field(id: 'city') }}
        address  = Domkey::PageObject.new elements, @container

        address.watirproc.should respond_to(:each_pair)
        address.element.should respond_to(:each_pair)
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
        address.element[:city].value.should eql 'Berlin'
        address.element[:city].set 'Austin'
        address.element[:city].value.should eql 'Austin'
      end

      it 'pageobject' do
        city     = Domkey::PageObject.new lambda { text_field(id: 'city') }
        elements = {street1: lambda { text_field(id: 'street1') }, city: city}

        address = Domkey::PageObject.new elements, @container

        address.watirproc.should respond_to(:each_pair)
        address.element.should respond_to(:each_pair)
        address.element[:street1].set 'helloworld'
        address.element[:street1].value.should eql 'helloworld'

      end

    end
  end
end
