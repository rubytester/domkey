require 'spec_helper'

describe Domkey::PageObject do

  before :all do
    Domkey.browser.goto("file://" + __dir__ + "/html/test.html")
  end

  it 'pageobject single element in container browser' do
    # single element is just a wrapper around watir object. no hashkey

    element   = lambda { text_field(id: 'street1') }
    container = lambda { Domkey.browser }
    street    = Domkey::PageObject.new element, container

    street.set 'Lamar' #sending string here so no hash like in composed object
    street.value.should eql 'Lamar'
    street.elements.should be_kind_of(Watir::TextField)
  end

  it 'pageobject elements in container browser' do
    # pageobjects is an object on the page. it can be an element (singluar text_field)
    # or composed of elements
    # elements = { key => proc }
    elements  = {
        street1: lambda { text_field(id: 'street1') },
        city:    lambda { text_field(id: 'city') }
    }

    # container (browser in this case)
    container = -> { Domkey.browser }

    # compose page object from elements and container
    # pageobject = PageObject.new elements, container
    address   = Domkey::PageObject.new elements, container

    address.elements[:street1].set 'helloworld'
    address.elements[:street1].value.should eql 'helloworld'

    # pageobject.set value
    # sends values to each element.set value
    value = {city: 'Berlin', street1: 'Fredrichstrasse'}
    address.set value

    ## pageobject.value => returns value from the page
    # asks each element for its value and aggregates value for entire pageobject
    expected_value = address.value

    # compare to value we sent earlier
    expected_value.should eql(value)

    address.elements[:city].value.should eql 'Berlin'
    address.elements[:city].set 'Austin'
    address.elements[:city].value.should eql 'Austin'
  end


end
