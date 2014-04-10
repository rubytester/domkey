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

  context 'Binder payload set and value' do

    it 'for single view' do
      payload = {city: 'Austin', street: 'Lamar'}

      binder = Domkey::View::Binder.new payload: payload, view: AddressView.new
      binder.set

      extracted = binder.value
      extracted.should eql payload
    end

    it 'for view within a view' do
      payload = {city:     'Austin', street: 'Lamar',
                 shipping: {city: 'Georgetown', street: 'Austin'}
      }

      binder = Domkey::View::Binder.new payload: payload, view: AddressView.new
      binder.set

      extracted = binder.value
      extracted.should eql payload

    end

    it 'for view view view' do

      payload = {city:     'Austin', street: 'Lamar',
                 shipping: {city:          'Georgetown', street: 'Austin',
                            # this is view within a view within original view
                            delivery_date: {month: 'delivery thing'}}
      }

      binder = Domkey::View::Binder.new payload: payload, view: AddressView.new
      binder.set


      extracted = binder.value
      extracted.should eql payload

    end

  end


  context 'View.binder convenience factory' do

    it 'single view' do

      payload             = {city: 'Austin', fruit: ['tomato', 'other']}
      binder              = AddressView.binder payload

      # default values when page loads before setting the values
      default_page_values = {:city=>"id city class city", :fruit=>["other"]}
      binder.value.should eql default_page_values
      binder.set

      extracted_payload = binder.value
      extracted_payload.should eql payload

    end

  end

end
