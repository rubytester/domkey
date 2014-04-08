module Domkey
  module View
    module Widgetry

      # Dispatcher chooser for a given Element
      # @param object [Element] thing that needs to be interacted with, i.e. Watir::Select, Watir::CheckBox, Selenium::Element etc...
      # @return [Widgetry::Dispatcher] (or subclass of) that handles the strategy for interacting with the element
      def self.dispatcher(object)
        object_class_name = object.class.name.split('::').last
        if const_defined? object_class_name.to_sym
          const_get("#{self}::#{object_class_name}").new(object)
        else
          Dispatcher.new(object)
        end
      end

      # Widgetry::Dispatcher is a communication object responsible for
      # receiving and transmitting messages to PageObject Element.
      # Client should subclass and provide desired interaction strategy that may differ from provided by default
      class Dispatcher < SimpleDelegator

        # @param [Element] thing that needs to be set i.e. Watir::Select, Watir::CheckBox etc...
        def initialize(object)
          __setobj__(object)
        end

        # @return [Element] subclasses use this to interact with original Elment wrapped by Dispacher
        def original
          __getobj__
        end

        # @return [Array<Option>] defaults to [] if original.options.empty?
        def options
          o = original.options
          o.count == 0 ? [] : o
        end

      end

      class Radio < Dispatcher

        # because radio.set does not take args
        def set value
          original.set
        end
      end

      class Select < Dispatcher

        def set value
          original.select value
        end

      end


    end
  end
end