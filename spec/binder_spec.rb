require 'spec_helper'

describe Domkey::View::Binder do

  class WithHooksView

    include Domkey::View

    dom(:city) { text_field(id: 'city1') }


    # target of before and after
    def fruit
      CheckboxGroup.new -> { checkboxes(name: 'fruit') }
    end

    def shipping
      ShippingWithHooksView.new
    end


    class Binder < Domkey::View::Binder

      def before_city

      end

      def after_city

      end

    end
  end

  class ShippingWithHooksView
    include Domkey::View
    dom(:city) { text_field(id: 'city2') }
    dom(:street) { text_field(id: 'street2') }

    class Binder < Domkey::View::Binder

      def before_city

      end

      def before_street

      end

    end

  end


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

  context 'Specialized Binder for a View' do

    it 'if view has Binder class then binder factory uses it' do
      payload = {city: 'Austin'}

      sb = WithHooksView.binder payload
      sb.should be_kind_of(WithHooksView::Binder)
      sb.should respond_to(:before_city)
      sb.should respond_to(:after_city)
    end

    it 'view uses generic binder' do
      payload = {city: 'Austin'}

      gb = AddressView.binder payload
      gb.should be_kind_of(Domkey::View::Binder)
      gb.should_not respond_to(:before_city)
    end

    it 'binder set calls before and after hooks' do
      payload = {city: 'Austin', fruit: []}

      binder = WithHooksView.binder payload
      binder.should_receive(:before_city).with(no_args).once
      binder.should_receive(:after_city).with(no_args).once
      binder.set
    end

    it 'binder descriptor is a view' do
      payload = {shipping: {street: 'foo'}}
      view    = WithHooksView.new

      ShippingWithHooksView::Binder.any_instance.should_receive(:before_street)
      ShippingWithHooksView::Binder.any_instance.should_not_receive(:before_city)
      view.set payload
    end


  end
end
