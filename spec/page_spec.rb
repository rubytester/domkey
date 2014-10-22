require 'spec_helper'

describe Domkey::View do

  class DomExampleView
    include Domkey::View

    #pageobject facade on single watir element
    dom(:street) { text_field(id: 'street1') }
    dom(:city) { text_field(id: 'city1') }
  end

  class DomkeyExampleView
    include Domkey::View

    #page object composed of more than one single elements (alternative is to have a view for it)
    domkey :address, street: -> { text_field(id: 'street1') }, city: -> { text_field(id: 'city1') }

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

  before :all do
    goto_html("test.html")
  end

  it 'dom is proc for single watir element' do
    view = DomExampleView.new
    expect(view).to respond_to(:street)
    expect(view.street).to be_a(Domkey::View::PageObject)

    # talk to browser
    view.street.set 'hello dom'
    expect(view.street.value).to eq 'hello dom'
  end

  it 'domkey is hash of procs' do
    view = DomkeyExampleView.new

    expect(view).to respond_to(:address)

    expect(view.address.package).to respond_to(:each_pair)
    expect(view.address.package).to_not be_empty

    view.address.package.each_pair do |k, v|
      expect(k).to be_a(Symbol)
      expect(v).to be_a(Domkey::View::PageObject)
    end

    expect(view.address.element).to respond_to(:each_pair)
    view.address.element.each_pair do |k, v|
      expect(v).to be_a(Watir::TextField) #resolve suitecase
    end

    expect(view.address.element.keys).to eq [:street, :city]

    # talk to browser
    payload = {street: 'Quantanemera', city: 'Austin'}
    view.address.set payload
    expect(view.address.value).to eq payload

    #set partial address (omit some keys)
    view.address.set street: 'Lamarski'
    expect(view.address.value).to eq street: 'Lamarski', city: 'Austin'

  end
end
