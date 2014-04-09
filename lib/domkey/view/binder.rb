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
          set_pageobject key, value
        end
        self
      end

      # extracts value for each pageobject identified by the payload
      # @returns [Hash] payload
      def value
        extracted = {}
        @payload.each_pair do |key, value|
          extracted[key] = value_for_pageobject(key, value)
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