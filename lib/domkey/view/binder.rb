module Domkey

  module View

    # Data transfer facilitator for the view
    # Sends data to view. Grabs data from view
    # Data is a payload of the view
    # For specialized transfer object a client would sublcass this Binder,
    # by default View.binder factory method is provided for regular data transfer object
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
    #      binder  = MyView.binder payload
    #      binder.set    #=> sets view.city with payload[:city] and view.fruit with payload[:fruit]
    #      binder.value  #=> returns {city: 'Austing', fruit: 'tomato'}
    #
    #      class MyBinder < Domkey::View::Binder
    #
    #      end
    #
    #      payload = {city: 'Mordor'}
    #      view    = MyView.new
    #      binder  = MyBinder.new view: view, payload: payload
    #      binder.set
    #
    class Binder

      attr_accessor :view, :payload

      def initialize payload: nil, view: nil
        @payload = payload
        @view    = view
      end

      # set each pageobject in the view with the value from the payload
      def set
        @payload.each_pair do |key, value|
          b, a      = "before_#{key}".to_sym, "after_#{key}".to_sym
          bs, s, as = "before_set_#{key}".to_sym, "set_#{key}".to_sym, "after_set_#{key}".to_sym
          __send__(b) if respond_to?(b)
          __send__(bs) if respond_to?(bs)
          respond_to?(s) ? __send__(s) : set_pageobject(key, value)
          __send__(as) if respond_to?(as)
          __send__(a) if respond_to?(a)
        end
      end

      # extracts value for each pageobject identified by the payload
      # @returns [Hash] payload
      def value
        extracted = {}
        @payload.each_pair do |key, value|
          b, a      = "before_#{key}".to_sym, "after_#{key}".to_sym
          bv, v, av = "before_value_#{key}".to_sym, "value_#{key}".to_sym, "after_value_#{key}".to_sym
          __send__(b) if respond_to?(b)
          __send__(bv) if respond_to?(bv)
          extracted[key] = respond_to?(v) ? __send__(v) : value_for_pageobject(key, value)
          __send__(av) if respond_to?(av)
          __send__(a) if respond_to?(a)
        end
        extracted
      end

      private

      def set_pageobject key, value
        @view.send(key).set value
      end

      def value_for_pageobject key, value
        object = @view.send(key)
        # object is pageobject
        if object.method(:value).parameters.empty?
          object.value
        else
          # object is another view that has collection of pageobject
          object.value value
        end
      end

      ## submits view
      #def submit
      #
      #end
      #
      ## is view ready?
      #def ready?
      #
      #end
    end
  end
end