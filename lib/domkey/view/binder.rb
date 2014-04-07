module Domkey

  module View

    # Data transfer facilitator for the view
    # Sends data to view. Grabs data from view
    # Data is a model of the view
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
    #      model  = {city: 'Austin', fruit: 'tomato'}
    #      binder = MyView.binder model
    #      binder.set #=> sets view.city with model[:city] and view.fruit with view_model[:fruit]
    #      binder.value #=> returns {city: 'Austing', fruit: 'tomato'}
    #
    #      class MyBinder < Domkey::View::Binder
    #
    #      end
    #
    #      model = {city: 'Mordor'}
    #      view  = MyView.new
    #      binder = MyBinder.new view: view, model: model
    #      binder.set
    #
    class Binder

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
        @model.each_pair do |key, value|
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