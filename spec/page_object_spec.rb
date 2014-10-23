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

  context 'when container is browser by default and' do

    it 'package is package' do
      package = -> { text_field(id: 'street1') }
      street  = Domkey::View::PageObject.new package

      expect(street.package).to be_a(Proc)
      expect(street.element).to be_a(Watir::TextField) #one default element

      # talk to browser
      street.set 'Lamar'
      expect(street.value).to eq 'Lamar'
      expect(street.options).to be_empty # by default options are empty
    end

    it 'package is pageobject' do
      # setup
      watir_object = -> { text_field(id: 'street1') }
      pageobject   = Domkey::View::PageObject.new watir_object

      # test
      street       = Domkey::View::PageObject.new pageobject

      expect(street.package).to be_a(Proc)
      expect(street.element).to be_a(Watir::TextField)


      # talk to browser
      street.set 'zooom' #sending string here so no hash like in composed object
      expect(street.value).to eq 'zooom'
      expect(street.options).to be_empty
    end

    it 'package is hash where values are packages' do
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

  context 'when container is pageobject' do

    it 'pageobject.dom becomes container' do
      browser   = -> { Domkey.browser }
      container = Domkey::View::PageObject.new -> { div(:id, 'container') }, browser

      e    = -> { text_field(class: 'city') }
      city = Domkey::View::PageObject.new e, container

      city.set 'Hellocontainer'
      expect(city.value).to eq 'Hellocontainer'
      expect(city.options).to be_empty

      #verify
      expect(Domkey.browser.div(:id, 'container').text_field(:class, 'city').value).to eq 'Hellocontainer'
    end
  end


end
