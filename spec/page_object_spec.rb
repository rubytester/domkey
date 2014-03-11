require 'spec_helper'

# methods each pageobject should have
# set value options elements

describe Domkey::Page::PageObject do

  before :all do
    Domkey.browser.goto("file://" + __dir__ + "/html/test.html")
  end

  context 'single element definition' do

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

    context 'when container is browser by default' do

      before :all do
        @container = lambda { Domkey.browser }
      end

      context 'errors' do

        before :all do
          watirproc = lambda { Object.new } #inappropriate object defined
          @po       = Domkey::Page::PageObject.new watirproc, @container
        end

        it 'init' do
          expect { Domkey::Page::PageObject.new 'hello', @container }.to raise_error(Domkey::PageObjectError, /Unable to construct PageObject/)
        end

        it 'set'

        it 'value'

        it 'options'

        it 'element'
      end


      it 'watirproc' do
        watirproc = lambda { text_field(id: 'street1') }
        street    = Domkey::Page::PageObject.new watirproc, @container

        street.set 'Lamar'
        street.value.should eql 'Lamar'
        street.element.should be_kind_of(Watir::TextField) #one default element
      end

      it 'pageobject' do
        watir_object             = lambda { text_field(id: 'street1') }
        street_from_watir_object = Domkey::Page::PageObject.new watir_object, @container
        street                   = Domkey::Page::PageObject.new street_from_watir_object, @container

        street.set 'zooom' #sending string here so no hash like in composed object
        street.value.should eql 'zooom'
        street.element.should be_kind_of(Watir::TextField)
      end

    end

  end

  context 'pageobject composed from several elements' do

    context 'container is browser' do

      before :all do
        @container = lambda { Domkey.browser }
      end

      it 'watirproc only' do
        elements = {street1: lambda { text_field(id: 'street1') }, city: lambda { text_field(id: 'city1') }}
        address  = Domkey::Page::PageObject.new elements, @container

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
        address.element(:city).value.should eql 'Berlin'
        address.element(:city).set 'Austin'
        address.element(:city).value.should eql 'Austin'

        expect { address.element(:wrongkey) }.to raise_error(KeyError)
        expect { address.set wrongkey: 'Value' }.to raise_error(KeyError)

      end

      it 'pageobject' do
        city     = Domkey::Page::PageObject.new lambda { text_field(id: 'city') }
        elements = {street1: lambda { text_field(id: 'street1') }, city: city}

        address = Domkey::Page::PageObject.new elements, @container

        address.watirproc.should respond_to(:each_pair)
        address.element.should respond_to(:each_pair)
        address.element[:street1].set 'helloworld'
        address.element[:street1].value.should eql 'helloworld'

      end

    end
  end
end
