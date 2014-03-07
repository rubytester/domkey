require 'spec_helper'

# view is a context for pageobject collection

module Domkey

  #view owns access to browser driver, provides browser as container to page objects
  #view is responsible for constructing pageobjects available in that view
  class View

    attr_accessor :browser

    def initialize browser=nil
      @browser = browser
    end

    def browser
      @browser ||= Domkey.browser
    end

    # pageobject factory
    def self.dom(key, &watirspec)
      send :define_method, key do
        PageObject.new watirspec, Proc.new { browser }
      end
    end

    # single element with default container browser
    dom(:street) { text_field(id: 'street1') }

    # single element take pageobject as its definition
    #dom(:street_again) { street }

    # single element where container is another pageobject
    dom(:city2) do
      PageObject.new(
          lambda { text_field(class: 'city') },
          lambda { div(id: 'container') }
      )
    end

    # TODO: pageobject matcher. Return page objects collection based on criteria runtime
    #dom(:city) { |arg| text_field(id:, arg) }

    dom(:street) { text_field(id: 'street1') }
    dom(:city) { text_field(id: 'city') }

    dom(:address_composed) do
      {city: city, street: street}
    end

    dom(:address) do
      {city: lambda { text_field(id: 'street1') },
       street: lambda { text_field(id: 'street1') }}
    end

    # composed element
    #dom(:address_bla) do
    #  dom(street:) { text_field(id: 'street1') }, dom(city:) { text_field(id:, 'city') }
    #end

    # pageobject from other page objects
    #dom(:address2) { PageObject.new(street: street, city: city) }
    #    dom(:feature) { CheckboxTextField.new(switch: '', blurb: '') }

  end
end

describe Domkey::View do

  before :all do
    #Domkey.browser.goto("file://" + __dir__ + "/html/test.html")
  end

  after :all do
#    Domkey.browser.quit
  end

  before :all do
#    @container = lambda { Domkey.browser }
  end

  it 'watirproc' do

    #watirproc = lambda { text_field(id: 'street1') }
    #street    = Domkey::PageObject.new watirproc, @container
    #street.set 'Lamar'
    #street.value.should eql 'Lamar'
    #street.element.should be_kind_of(Watir::TextField) #one default element

    view = Domkey::View.new
    view.should respond_to(:street) #.value.should eql 'Lamar'
    view.street.should be_kind_of(Domkey::PageObject)

    # runtime
    view.street.element.exists?.should be_false #not there yet
    Domkey.browser.goto("file://" + __dir__ + "/html/test.html")
    view.street.set 'BlaBlaBla'

    view.city2.set 'asdfasdfasdfadsf'

  end

  #it 'pageobject' do
  #  watir_object             = lambda { text_field(id: 'street1') }
  #  street_from_watir_object = Domkey::PageObject.new watir_object, @container
  #  street                   = Domkey::PageObject.new street_from_watir_object, @container
  #
  #  street.set 'zooom' #sending string here so no hash like in composed object
  #  street.value.should eql 'zooom'
  #  street.element.should be_kind_of(Watir::TextField)
  #end
end
