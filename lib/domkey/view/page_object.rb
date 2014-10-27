require 'domkey/view/widgetry/package'
require 'domkey/view/widgetry/dispatcher'
require 'domkey/view/widgetry/element_delegator'

module Domkey

  module View

    # PageObject represents a semantically essential watir elements package in a View
    # It is an object that responds to set, value and options as the main way of sending data to it.
    # it is composed of one or more watir elements.
    # PageObject encapuslates the widgetry of DOM elements to provide semantic interface to the user of the widgetry
    #
    # Compose PageObject with package and container
    #
    # What is a container? it's a proc, a callable object that plays a role of a container for package widgetry
    # container can be one of:
    # - a proc holding watir element. Defaults to browser as ultimate container for all elements
    # - a pageobject
    #
    # What is package? it's a proc of DOM elements widgetry that can be found inside the container
    # package can be one of the following:
    #   - a proc holding definition of a single watir element i.e. `-> { text_field(:id, 'foo')}`
    #   - a pageobject i.e. previously instantiated definition
    #   - a hash where key is the name of PageObject that collaborates and value a proc for watier element or pageobject
    #
    # Usage:
    # Clients would not usually instantate this class.
    # A client class which acts as a View would use dom factory methods to create PageObjects
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
      include Widgetry::ElementDelegator

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
        elsif package.respond_to?(:package, true) #pageobject
          return package.package
        elsif package.respond_to?(:call) #proc
          package
        else
          fail Exception::Error, "package must be kind of hash, pageobject or watirelement but I got this: #{package}"
        end
      end
    end

    module ClassMethods

      # PageObject factory where package is a single watir element wrapper
      # example:
      #   dom(:foo) {text_field(id: 'hello_world')}
      #
      def dom(key, &package)
        send :define_method, key do
          PageObject.new package, -> { watir_container }
        end
      end

      # PageObject factory where package is a keyed hash of watir element procs. Capture elements that compose this PageObject
      # example:
      # domkey :foo, switch: -> { checkbox(id: 'feature_checkbox1') }, blurb: -> { textarea(id: 'feature_textarea1') }}
      # builds a PageObject where package is a hash of two elements with keys :switch and :blurb
      def domkey(key, hash)
        send :define_method, key do
          PageObject.new hash, -> { watir_container }
        end
      end

    end
  end
end