require 'spec_helper'
module DomkeyExample
  class DomIsWatirproc
    include Domkey::Page
    #pageobject is watirproc
    dom(:street) { text_field(id: 'street1') }
    dom(:city) { text_field(id: 'city1') }
  end

  class DomIsHashOfDom # or doom
    include Domkey::Page

    # Possible api to compose pageobject with pair of hash => lambda definition
    dom(:address) do
      {
          street: -> { text_field(id: 'street1') },
          city:   -> { text_field(id: 'city1') }
      }
    end

    ## alternative api design

    #dom(:address) do
    #  Proc.new { Hash.new(:street => dom(:street) { text_field(id: 'street2') }) }
    #  {:street => (dom(:street) { text_field(id: 'street2') })} #literal hash
    #end

    #composed
    #dom(:address) do
    #  {street: street,
    #   city:   city}
    #end

    ## pageobject is composed
    #domkey(:address) do
    #  dom(:street) { text_field(id: 'street1') }
    #  dom(:city) { text_field(id: 'city') }
    #end
  end
end

describe Domkey::Page do

  before :all do
    Domkey.browser.goto("file://" + __dir__ + "/html/test.html")
  end

  it 'domw is watirproc' do
    view = DomkeyExample::DomIsWatirproc.new
    view.should respond_to(:street)
    view.street.should be_kind_of(Domkey::Page::PageObject)

    # talk to browser
    view.street.set 'hello dom'
    view.street.value.should eql 'hello dom'
  end

  it 'dom is hash of dom' do
    view = DomkeyExample::DomIsHashOfDom.new

    view.should respond_to(:address)

    view.address.watirproc.should respond_to(:each_pair)
    view.address.watirproc.should_not be_empty

    view.address.watirproc.each_pair do |k, v|
      k.should be_kind_of(Symbol)
      v.should be_kind_of(Domkey::Page::PageObject) #should respond to set and value
    end

    view.address.element.should respond_to(:each_pair)
    view.address.element.each_pair do |k, v|
      v.should be_kind_of(Watir::TextField) #resolve suitecase
    end


    view.address.element.keys.should eql [:street, :city]

    # talk to browser
    value = {street: 'Quantanemera', city: 'Austin'}
    view.address.set value
    v = view.address.value
    v.should eql value

    #set partial address (omit some keys)
    view.address.set street: 'Lamarski'
    view.address.value.should eql street: 'Lamarski', city: 'Austin'

  end
end
