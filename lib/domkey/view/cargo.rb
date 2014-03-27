module Domkey

  module View

    # Data shipping between Model and View
    # Sends data to view. Grabs data from view
    #
    # For specialized transfer object a client would sublcass this Cargo,
    # by default View.cargo factory method is provided for regular data transfer object
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
    #      model      = {city: 'Austin', fruit: 'tomato'}
    #      cargo = MyView.cargo model
    #      cargo.set #=> sets view.city with model[:city] and view.fruit with model[:fruit]
    #      cargo.value #=> returns {city: 'Austing', fruit: 'tomato'}
    #
    #      class MyCargo < Domkey::View::Cargo
    #
    #      end
    #
    #      model = {city: 'Mordor'}
    #      view  = MyView.new
    #      cargo = MyCargo.new view: view, model: model
    #      cargo.set
    #
    class Cargo

      attr_accessor :view, :model

      def initialize model: nil, view: nil
        @model = model
        @view  = view
      end

      # set each pageobject in the view with the value from the model
      def set
        @model.each_pair do |key, value|
          set_pageobject key, value
        end
        self
      end

      # extracts value for each pageobject identified by the model
      # @returns [Model]
      def value
        extracted = {}
        @model.each_key do |key|
          extracted[key] = value_for_pageobject(key)
        end
        extracted
      end

      private

      def set_pageobject key, value
        @view.send(key).set value
      end

      def value_for_pageobject key
        @view.send(key).value
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