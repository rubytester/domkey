require 'spec_helper'

# view is a context for pageobject collection

module Domkey

  class View

    def initialize browser=nil #Domkey.browser
      @browser = browser
    end

    def container
      lambda { Domkey.browser }
    end

    def self.dom(key, &watirspec)
      send :define_method, key do
        PageObject.new watirspec, &container
      end
    end

    # single element
    dom(:street) { text_field(id: 'street1') }
    #dom(:city) { street }
    #dom(:city) { |arg| text_field(id:, arg) }

    # composed element
    #dom(:address) do
    #  dom(street:) { text_field(id: 'street1') }
    #  dom(city:) { text_field(id:, 'city') }
    #
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
    Domkey.browser.goto("file://" + __dir__ + "/html/test.html")
    view.street.set 'BlaBlaBla'

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
