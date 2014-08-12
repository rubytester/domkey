require 'spec_helper'

describe Domkey::View::Binder do

  class WithBinderClassMethodView
    include Domkey::View

    dom(:city) { text_field(id: 'city1') }

    # setup custom binder mechanism for default interaction with the view
    # class Binder < Domkey::View::Binder
    binder do
      def before_city
        # hook in custom binder for key == :city
      end
    end

  end

  class AddressView
    include Domkey::View
    dom(:city) { text_field(id: 'city1') }
    dom(:street) { text_field(id: 'street1') }

    # this does not exist
    dom(:state) { text_field(id: 'state1') }

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

  # example of all possible hooks for keys taken from payload
  class BinderKeyHooks < Domkey::View::Binder

    def before_city
      # before binder message to :set, :value, :options for key == city
    end

    def before_set_city
      # before binder.set for key == city
    end

    def before_value_city
      # before binder.value for key == city
    end

    def before_options_city
      # before binder.options for key == city
    end

    def set_city
      #hijack and custom set value for key == city
    end

    def value_city
      #hijack and custom get value for key == city
    end

    def options_city
      #hijack and custom get options for key == city
    end

    def after_set_city
      #after binder.set for key == city
    end

    def after_value_city
      #after binder.value for key == city
    end

    def after_options_city
      #after binder.options for key == city
    end

    def after_city
      # after message to binder :set, :value, :options for key == city
    end
  end

  before :each do
    goto_html("test.html")
  end

  context 'Binder payload set and value' do


    context 'when pageobject expected to be present but object not there' do

      before :all do
        Watir.default_timeout = 0.1
        @payload = {state: 'not there'}
        @view    = AddressView.new
      end

      after :all do
        Watir.default_timeout = nil
      end

      it 'set value' do
        expect { @view.set(@payload) }.to raise_error(Domkey::Exception::NotFoundError)
      end

      it 'get value' do
        expect { @view.value(@payload) }.to raise_error(Domkey::Exception::NotFoundError)
      end

      it 'options' do
        expect { @view.options(@payload) }.to raise_error(Domkey::Exception::NotFoundError)
      end

    end

    context "custom inner binder class" do

      it 'binder class in view' do
        view       = WithBinderClassMethodView.new
        metabinder = WithBinderClassMethodView::Binder.new
        metabinder.should respond_to(:before_city)
      end

      it 'view invokes it for actions' do
        payload = {city: 'Bla'}
        view    = WithBinderClassMethodView.new
        WithBinderClassMethodView::Binder.any_instance.should_receive(:before_city)
        view.set payload
      end
    end

    it 'for single view' do
      payload = {city: 'Austin', street: 'Lamar'}

      binder = Domkey::View::Binder.new payload: payload, view: AddressView.new
      binder.set

      extracted = binder.value
      extracted.should eql payload
    end

    it 'when view has undefined key' do
      payload = {cityyyy: 'Austin'}

      binder = Domkey::View::Binder.new payload: payload, view: AddressView.new
      expect { binder.set }.to raise_error(Domkey::Exception::NotImplementedError)
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

      it 'set' do
        binder = BinderKeyHooks.new payload: {city: 'Austin'}, view: AddressView.new
        binder.should_receive(:before_city).with(no_args).once
        binder.should_receive(:before_set_city).with(no_args).once
        binder.should_receive(:set_city).with(no_args).once
        binder.should_receive(:after_set_city).with(no_args).once
        binder.should_receive(:after_city).with(no_args).once
        binder.set
      end

      it 'value' do
        binder = BinderKeyHooks.new payload: {city: 'Austin'}, view: AddressView.new
        binder.should_receive(:before_city).with(no_args).once
        binder.should_receive(:before_value_city).with(no_args).once
        binder.should_receive(:value_city).with(no_args).once
        binder.should_receive(:after_value_city).with(no_args).once
        binder.should_receive(:after_city).with(no_args).once
        binder.value
      end

      it 'options' do
        binder = BinderKeyHooks.new payload: {city: 'Austin'}, view: AddressView.new
        binder.should_receive(:before_city).with(no_args).once
        binder.should_receive(:before_options_city).with(no_args).once
        binder.should_receive(:options_city).with(no_args).once
        binder.should_receive(:after_options_city).with(no_args).once
        binder.should_receive(:after_city).with(no_args).once
        binder.options
      end
    end

    context 'Binder options' do

      it 'when pageobject does not have selectable options' do
        payload = {city: '', street: ''}
        binder  = Domkey::View::Binder.new payload: payload, view: AddressView.new
        binder.options.should eql({:city => [], :street => []})
        binder.options
      end

      context 'when pageobject has selectable options' do

        it 'default options' do
          payload = {fruit: 'tomato'}
          binder  = Domkey::View::Binder.new payload: payload, view: AddressView.new
          binder.options.should eql(:fruit => ["cucumber", "tomato", "other"])
        end

        it 'options with specific qualifier' do
          # qualifed means asking for :text, :value, :label, :index (other than default)
          payload = {fruit: :text}
          binder  = Domkey::View::Binder.new payload: payload, view: AddressView.new
          binder.options.should eql(:fruit => [{:text => "Cucumberama"}, {:text => "Tomatorama"}, {:text => "Other"}])
        end

        it 'options with 2 specific qualifiers' do
          # qualifed means asking for :text, :value, :label, :index (other than default)
          payload = {fruit: [:text, :value]}
          binder  = Domkey::View::Binder.new payload: payload, view: AddressView.new
          binder.options.should eql(:fruit => [{:text => "Cucumberama", :value => "cucumber"}, {:text => "Tomatorama", :value => "tomato"}, {:text => "Other", :value => "other"}])
        end

      end
    end
  end

end
