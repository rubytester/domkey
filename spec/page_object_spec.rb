require 'spec_helper'

describe Domkey::PageObject do

  before :all do
    Domkey.browser.goto("file://" + __dir__ + "/html/test.html")
  end

  it 'initialize' do
    # elements
    street1 = lambda { text_field(id: 'street1') }
    city    = lambda { text_field(id: 'city') }

    # compose page object
    address = Domkey::PageObject.new city: city, street1: street1

    # set page object
    model   = {city: 'Berlin', street1: 'Fredrichstrasse'}
    address.set model
    value = address.value(model)
    model.should eq(value)
  end
end
