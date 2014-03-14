require 'spec_helper'
module DomkeyExample
  class DomIspackage
    include Domkey::View
    #pageobject is package
    dom(:street) { text_field(id: 'street1') }
    dom(:city) { text_field(id: 'city1') }
  end

  class DomIsHashOfDom # or doom
    include Domkey::View

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

describe Domkey::View do

  before :all do
    Domkey.browser.goto("file://" + __dir__ + "/html/test.html")
  end

  it 'dom is package' do
    view = DomkeyExample::DomIspackage.new
    view.should respond_to(:street)
    view.street.should be_kind_of(Domkey::View::PageObject)

    # talk to browser
    view.street.set 'hello dom'
    view.street.value.should eql 'hello dom'
  end

  it 'dom is hash of dom' do
    view = DomkeyExample::DomIsHashOfDom.new

    view.should respond_to(:address)

    view.address.package.should respond_to(:each_pair)
    view.address.package.should_not be_empty

    view.address.package.each_pair do |k, v|
      k.should be_kind_of(Symbol)
      v.should be_kind_of(Domkey::View::PageObject) #should respond to set and value
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
