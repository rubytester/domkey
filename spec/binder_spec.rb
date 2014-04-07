require 'spec_helper'

describe Domkey::View::Binder do

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

    binder = Domkey::View::Binder.new model: model, view: AddressView.new
    binder.set
    extracted = binder.value
    extracted.should eql model
  end

  it 'view within view' do
    model = {city:     'Austin',
             street:   'Lamar',
             shipping: {city:   'Georgetown',
                        street: 'Austin'}
    }

    binder = Domkey::View::Binder.new model: model, view: AddressView.new
    binder.set
    extracted = binder.value
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

    binder = Domkey::View::Binder.new model: model, view: AddressView.new
    binder.set
    extracted = binder.value
    extracted.should eql model
  end

  it 'binder' do
    model = {city: 'Mordor'}

    view  = AddressView.new
    binder = Domkey::View::Binder.new view: view, model: model
    binder.set
    scraped_model = binder.value

    scraped_model.should eql model
  end

  it 'pageobject' do

    model               = {city: 'Austin', fruit: ['tomato', 'other']}
    binder               = AddressView.binder model

    # default values when page loads before setting the values
    default_page_values = {:city=>"id city class city", :fruit=>["other"]}
    binder.value.should eql default_page_values
    binder.set

    extracted_model = binder.value
    extracted_model.should eql model

  end

end
