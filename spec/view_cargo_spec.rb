require 'spec_helper'

describe Domkey::View::Cargo do

  class AddressView
    include Domkey::View
    dom(:city) { text_field(id: 'city1') }
    dom(:street) { text_field(id: 'street1') }

    # semantic descriptor that returns another view
    # the other view has PageObjects that participate in this view
    def shipping
      ShippingAddressView.new
    end

    # semantic descriptor that returns PageObject
    def fruit
      CheckboxGroup.new -> { checkboxes(name: 'fruit') }
    end

  end

  class ShippingAddressView
    include Domkey::View
    dom(:city) { text_field(id: 'city2') }
    dom(:street) { text_field(id: 'street2') }

    def delivery_date
      DateView.new
    end
  end

  class DateView
    include Domkey::View
    dom(:month) { text_field(id: 'month_field') }
  end

  before :each do
    goto_html("test.html")
  end

  it 'view within pageobject' do
    model = {city:   'Austin',
             street: 'Lamar'}

    cargo = Domkey::View::Cargo.new model: model, view: AddressView.new
    cargo.set
    extracted = cargo.value
    extracted.should eql model
  end

  it 'view within view' do
    model = {city:     'Austin',
             street:   'Lamar',
             shipping: {city:   'Georgetown',
                        street: 'Austin'}
    }

    cargo = Domkey::View::Cargo.new model: model, view: AddressView.new
    cargo.set
    extracted = cargo.value
    extracted.should eql model
  end

  it 'view view view' do
    model = {city:     'Austin',
             street:   'Lamar',
             shipping: {city:          'Georgetown',
                        street:        'Austin',
                        # this is view within a view within original view
                        delivery_date: {month: 'delivery thing'}}
    }

    cargo = Domkey::View::Cargo.new model: model, view: AddressView.new
    cargo.set
    extracted = cargo.value
    extracted.should eql model
  end

  it 'cargo' do
    model = {city: 'Mordor'}

    view  = AddressView.new
    cargo = Domkey::View::Cargo.new view: view, model: model
    cargo.set
    scraped_model = cargo.value

    scraped_model.should eql model
  end

  it 'pageobject' do

    model               = {city: 'Austin', fruit: ['tomato', 'other']}
    cargo               = AddressView.cargo model

    # default values when page loads before setting the values
    default_page_values = {:city=>"id city class city", :fruit=>["other"]}
    cargo.value.should eql default_page_values
    cargo.set

    extracted_model = cargo.value
    extracted_model.should eql model

  end

end
