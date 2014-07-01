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
      #
    end
  end

  class ShippingWithHooksView
    include Domkey::View
    dom(:city) { text_field(id: 'city2') }
    dom(:street) { text_field(id: 'street2') }

    class Binder < Domkey::View::Binder

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

  class BinderWithHooks < Domkey::View::Binder

    def before_city
      #
    end

    def set_city
      #
    end

    def after_city
      #
    end
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

    context 'hooks' do

      it 'before set after' do
        binder = BinderWithHooks.new payload: {city: 'Austin'},
                                     view:    AddressView.new
        binder.should_receive(:before_city).with(no_args).once
        binder.should_receive(:set_city).with(no_args).once
        binder.should_receive(:after_city).with(no_args).once
        binder.set
      end
    end

  end


  context 'View.binder convenience factory' do

    it 'by default uses Binder class' do
      payload = {city: 'Austin', fruit: ['tomato', 'other']}
      binder  = AddressView.binder payload
      binder.should be_kind_of(Domkey::View::Binder)
    end

    it 'when View class has special inner Binder class that binder is used' do
      sb = WithHooksView.binder({city: 'Austin'})
      sb.should be_kind_of(WithHooksView::Binder)
    end
  end
end
