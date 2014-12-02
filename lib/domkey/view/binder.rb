module Domkey

  module View

    # Data transfer facilitator for the view
    # Sends data to view. Grabs data from view
    # Data is a payload of the view
    # For specialized transfer object a client would sublcass this Binder
    #
    # @usage
    #
    #      class MyView
    #        include Domkey::View
    #
    #        dom(:city) { text_field(id: 'city2') }
    #
    #        def fruit
    #          RadioGroup.new -> { checkboxes(name: 'fruit') }
    #        end
    #      end
    #
    #      payload = {city: 'Austin', fruit: 'tomato'}
    #      view  = MyView.new
    #      view.set payload  #=> sets view.city with payload[:city] and view.fruit with payload[:fruit]
    #      view.value payload  #=> returns {city: 'Austing', fruit: 'tomato'}
    #
    #   View uses its own binder to setup hooks when interacting with pageobjects identified by keys in payload
    #
    #     class MyView
    #       include Domkey::View
    #
    #       dom(:city) { text_field(id: 'city2') }
    #
    #       binder do
    #         def before_city
    #           # code that runs before city page object is interacted
    #         end
    #       end
    #       payload = {city: 'Mordor'}
    #       view    = MyView.new
    #       view.set payload # => and before_city hook will be called when setting key :city
    class Binder

      attr_accessor :view, :payload

      def initialize payload: nil, view: nil
        @payload = payload
        @view    = view
      end

      # set each pageobject in the view with the value from the payload
      def set
        @payload.each_pair do |key, value|
          @key, @value = key, value
          b, a         = "before_#{key}".to_sym, "after_#{key}".to_sym
          bs, s, as    = "before_set_#{key}".to_sym, "set_#{key}".to_sym, "after_set_#{key}".to_sym
          __send__(b) if respond_to?(b)
          __send__(bs) if respond_to?(bs)
          respond_to?(s) ? __send__(s) : set_pageobject
          __send__(as) if respond_to?(as)
          __send__(a) if respond_to?(a)
        end
      end

      # extracts value for each pageobject identified by the payload key => value pair
      # where value may be a specific qualifier to extract for option selectable pageobjects
      # @return [Hash] payload
      def value
        extracted = {}
        @payload.each_pair do |key, value|
          @key, @value = key, value
          b, a         = "before_#{key}".to_sym, "after_#{key}".to_sym
          bv, v, av    = "before_value_#{key}".to_sym, "value_#{key}".to_sym, "after_value_#{key}".to_sym
          __send__(b) if respond_to?(b)
          __send__(bv) if respond_to?(bv)
          extracted[key] = respond_to?(v) ? __send__(v) : value_for_pageobject
          __send__(av) if respond_to?(av)
          __send__(a) if respond_to?(a)
        end
        extracted
      end


      # extracts options for each pageobject identified by the payload key => value pair
      # where value may be a specific option qualifier to extract for option selectable pageobjects
      # @return [Hash] payload
      def options
        extracted = {}
        @payload.each_pair do |key, value|
          @key, @value = key, value
          b, a         = "before_#{key}".to_sym, "after_#{key}".to_sym
          bo, o, ao    = "before_options_#{key}".to_sym, "options_#{key}".to_sym, "after_options_#{key}".to_sym
          __send__(b) if respond_to?(b)
          __send__(bo) if respond_to?(bo)
          extracted[key] = respond_to?(o) ? __send__(o) : options_for_pageobject
          __send__(ao) if respond_to?(ao)
          __send__(a) if respond_to?(a)
        end
        extracted
      end

      private

      def when_view_responds_to_key
        if @view.respond_to?(@key)
          @view.__send__(@key)
        else
          raise Exception::NotImplementedError, "View doesn't respond to #{@key}, expected '#{@view.class}##{@key}' to be defined"
        end
      end

      def options_for_pageobject
        object = when_view_responds_to_key
        if object.method(:options).parameters.empty?
          expected_to_be_present(object).options
        else
          expected_to_be_present(object).options @value
        end
      end

      def set_pageobject
        expected_to_be_present(when_view_responds_to_key).set @value
      end

      def value_for_pageobject
        object = when_view_responds_to_key
        if object.method(:value).parameters.empty?
          expected_to_be_present(object).value
        else
          expected_to_be_present(object).value @value
        end
      end

      # we expect pageobject to be present for interaction
      # if not present we raise NotFoundError.
      # Use Watir.default_timeout value to wait until element present
      def expected_to_be_present(object)
        object.wait_until_present if object.respond_to?(:wait_until_present)
        object
      rescue Watir::Wait::TimeoutError => e
        raise Exception::NotFoundError, "Binder expected pageobject: '#{@view.class}##{@key}' to be present: #{e.message}"
      end
    end

    module FactoryMethods

      # custom inner Binder class for the current view
      # used to create custom binder hooks for :set, :value, :options actions
      # example:
      #
      #     class MyView
      #       include Domkey::View
      #       dom(:foo) { text_field(id: 'foo')}
      #       binder do
      #         # provide your hooks here for custom binder
      #         # example
      #         def before_foo
      #           # do stuff before interating with pageobject :foo in this view
      #         end
      #       end
      #     end
      #     view = MyView.new
      #     view.set :foo => 'foo value' # ensures before_foo will be called in the custom binder

      def binder &blk
        klass = self.const_set("Binder", Class.new(::Domkey::View::Binder))
        klass.module_eval &blk
      end

    end
  end
end