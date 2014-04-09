require 'domkey/view/widgetry/package'
require 'domkey/view/widgetry/dispatcher'

module Domkey

  module View

    # PageObject represents an semantically essential area in a View
    # It is an object that responds to set and value as the main way of sending data to it.
    # it is composed of one or more watir elements.
    # PageObject encapuslates the widgetry of DOM elements to provide semantic interfact to the user of the widgetry
    #
    # Compose PageObject with package and container
    #
    # What is a container? it's a proc, a callable object that plays a role of a container for package widgetry
    # container can be one of:
    # - browser (default)
    # - a pageobject
    #
    # What is package? it's a proc of DOM elements widgetry that can be found inside the container
    # package can be one of the following:
    #   - definition of single watir element i.e. `-> { text_field(:id, 'foo')}`
    #   - a pageobject i.e. previously instantiated definition
    #   - hash where key defines subelement and value a definition or pageobject
    #
    # Usage:
    # Clients would not usually instantate this class.
    # A client class which acts as a View would use a :dom factory method to create PageObjects
    # Example:
    #
    #        class MyView
    #          include Domkey::View
    #
    #          dom(:headline) { text_field(id:, 'some_desc_text') }
    #
    #          def property
    #            PropertyPanel.new browser.div(id: 'container')
    #          end
    #        end
    #
    #        class PropertyPanel
    #          include Domkey::View
    #          dom(:headline) { text_field(class: 'headline_for_house') }
    #        end
    #
    #        view = MyView.new
    #        view.headline.set 'HomeAway Rules!'
    #        view.value #=> returns 'HomeAway Rules!'
    #        view.property.headline.set 'Awesome Vactaion Home'
    #        view.property.headline.value #=> returns 'Awesome Vaction Home'
    #
    class PageObject

      # @api private
      include Widgetry::Package

      # Each Semantic PageObject defines what value means for itself
      # @param [SemanticValue] Delegated to Watir::Element and we expect it to respond to set
      # @parma [Hash{Symbol => SemanticValue}]
      def set value
        return widgetry_dispatcher.set value unless value.respond_to?(:each_pair)
        value.each_pair { |k, v| package.fetch(k).set(v) }
      end

      alias_method :value=, :set

      # Each Semantic PageObject defines what value means for itself
      # @return [SemanticValue] delegated to WebdriverElement and we expect it to respond to value message
      # @return [Hash{Symbol => SemanticValue}]
      def value
        return widgetry_dispatcher.value unless package.respond_to?(:each_pair)
        Hash[package.map { |key, pageobject| [key, pageobject.value] }]
      end

      def options
        return widgetry_dispatcher.options unless package.respond_to?(:each_pair)
        Hash[package.map { |key, pageobject| [key, pageobject.options] }]
      end


      # @api private
      # delegate to element when element responds to message
      def method_missing(message, *args, &block)
        if element.respond_to?(message)
          element.__send__(message, *args, &block)
        else
          super
        end
      end

      # @api private
      # ruturn true when element.respond_to? message so we can delegate with confidence
      def respond_to_missing?(message, include_private = false)
        element.respond_to?(message) || super
      end

      private

      # wrap instantiator with strategy for setting and getting value for underlying object
      # expects that element to respond to set and value
      # @returns [Widgetry::Dispatcher] that responds to set, value, options
      def widgetry_dispatcher
        Widgetry.dispatcher(instantiator)
      end

      # @api private
      # Recursive. Examines each packages and turns each Proc into PageObject
      def initialize_this package
        if package.respond_to?(:each_pair) #hash
          Hash[package.map { |key, package| [key, PageObject.new(package, container)] }]
        else
          if package.respond_to?(:call) #proc
            begin
              # peek inside suitcase that is proc. XXX ouch, ugly
              peeked_inside = package.call
            rescue StandardError
              return package #suitecase exploded, proc returned
            end
            if peeked_inside.kind_of?(Hash)
              return initialize_this peeked_inside
            elsif peeked_inside.kind_of?(Watir::Container)
              return lambda { peeked_inside }
            elsif peeked_inside.kind_of?(PageObject)
              return peeked_inside.package
            else
              fail Exception::Error, "package must be kind of hash, watirelement or pageobject but I got this: #{package}"
            end
          elsif package.respond_to?(:package, true) #pageobject
            return package.package
          else
            fail Exception::Error, "package must be kind of hash, watirelement or pageobject but I got this: #{package}"
          end
        end
      end
    end
  end
end