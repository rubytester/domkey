require 'spec_helper'

# methods each pageobject should have
# set value options elements

describe Domkey::View::PageObject do

  before :all do
    goto_html("test.html")
  end

  context 'exceptions' do

    it 'bad proc for package argument' do
      # wrong definition but it's a proc and we don't peek inside
      expect { Domkey::View::PageObject.new -> { 'foo' } }.not_to raise_error
    end

    it 'bad object for package argument' do
      expect { Domkey::View::PageObject.new(Object.new) }.to raise_error(Domkey::Exception::Error)
    end
  end

  context 'package initialize' do

    it 'as proc' do
      package = -> { text_field(id: 'street1') }
      street  = Domkey::View::PageObject.new package

      expect(street.package).to be_a(Proc)
      # resolve proc to watir element
      expect(street.element).to be_a(Watir::TextField) #one default element

      # talk to browser
      street.set 'Lamar'
      expect(street.value).to eq 'Lamar'
      expect(street.options).to be_empty # by default options are empty
    end

    it 'as pageobject' do
      # setup
      package    = -> { text_field(id: 'street1') }
      pageobject = Domkey::View::PageObject.new package

      # test
      street     = Domkey::View::PageObject.new pageobject

      expect(street.package).to be_a(Proc)
      expect(street.element).to be_a(Watir::TextField)


      # talk to browser
      street.set 'zooom' #sending string here so no hash like in composed object
      expect(street.value).to eq 'zooom'
      expect(street.options).to be_empty
    end

    it 'as hash where values are packages' do
      hash    = {street1: -> { text_field(id: 'street1') },
                 city:    -> { text_field(id: 'city1') }}
      address = Domkey::View::PageObject.new hash

      expect(address.package).to respond_to(:each_pair)
      address.package.each_pair do |k, v|
        expect(k).to be_a(Symbol)
        expect(v).to be_a(Domkey::View::PageObject)
      end

      # elements
      expect(address.element).to respond_to(:each_pair)
      address.element.each_pair do |k, v|
        expect(k).to be_a(Symbol)
        expect(v).to be_a(Watir::TextField)
      end

      # talk to browser
      expect(address.options).to eq :street1 => [], :city => []

      # pageobject.set value
      # sends values to each element.set value
      payload = {:street1 => 'Hashstreet', :city => 'Hashcity'}
      address.set payload

      ## pageobject.value => returns value from the page
      # asks each element for its value and aggregates value for entire pageobject
      expect(address.value).to eq payload

      # individual
      address.element[:street1].set 'helloworld'
      expect(address.element[:street1].value).to eq 'helloworld'

      # individual (alternative)
      address.element(:city).set 'Berlin'
      expect(address.element(:city).value).to eq 'Berlin'
    end
  end

  context 'container initialize' do

    it 'default browser becomes container' do
      o = Domkey::View::PageObject.new -> { div(:id, 'container') }
      expect(o.watir_container).to be_a(Watir::Browser)
    end

    it 'watir element becomes container' do
      c = Domkey.browser.div(id: 'container')
      o = Domkey::View::PageObject.new -> { text_field(class: 'city') }, c
      expect(o.watir_container).to be_a(Watir::Div)
      # browser is Watir::Browser
      expect(o.browser).to be_a(Watir::Browser)
    end

    it 'proc wrapping watir element which becomes container' do
      c = -> { Domkey.browser.div(id: 'container') }
      o = Domkey::View::PageObject.new -> { text_field(class: 'city') }, c
      expect(o.watir_container).to be_a(Watir::Div)
    end

    it 'pageobject package should become container' do
      browser   = -> { Domkey.browser }
      container = Domkey::View::PageObject.new -> { div(:id, 'container') }, browser

      e    = -> { text_field(class: 'city') }
      city = Domkey::View::PageObject.new e, container

      expect(city.watir_container).to be_a(Watir::Div)

      city.set 'Hellocontainer'
      expect(city.value).to eq 'Hellocontainer'
      expect(city.options).to be_empty

      #verify
      expect(Domkey.browser.div(:id, 'container').text_field(:class, 'city').value).to eq 'Hellocontainer'
    end
  end


end
