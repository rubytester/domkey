require 'domkey/view/widgetry/package'
require 'domkey/view/widgetry/dispatcher'
require 'domkey/view/widgetry/element_delegator'

module Domkey

  module View

    # Component represents a semantically essential watir elements package in a View
    # It is an object that responds to set, value and options as the main way of sending data to it.
    # it is composed of one or more watir elements.
    # Component encapuslates the widgetry of DOM elements to provide semantic interface to the user of the widgetry
    #
    # Compose Component with package and container
    #
    # What is a container? it's a proc, a callable object that plays a role of a container for package widgetry
    # container can be one of:
    # - a proc holding watir element. Defaults to browser as ultimate container for all elements
    # - a page_component
    #
    # What is package? it's a proc of DOM elements widgetry that can be found inside the container
    # package can be one of the following:
    #   - a proc holding definition of a single watir element i.e. `-> { text_field(:id, 'foo')}`
    #   - a page_component i.e. previously instantiated definition
    #   - a hash where key is the name of Component that collaborates and value a proc for watier element or page_component
    #
    # Usage:
    # Clients would not usually instantate this class.
    # A client class which acts as a View would use dom factory methods to create Components
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
    class Component

      # @api private
      include Widgetry::Package
      include Widgetry::ElementDelegator

      # Each Semantic Component defines what value means for itself
      # @param [SemanticValue] Delegated to Watir::Element and we expect it to respond to set
      # @parma [Hash{Symbol => SemanticValue}]
      def set value
        return widgetry_dispatcher.set value unless value.respond_to?(:each_pair)
        value.each_pair { |k, v| package.fetch(k).set(v) }
      end

      alias_method :value=, :set

      # Each Semantic Component defines what value means for itself
      # @return [SemanticValue] delegated to WebdriverElement and we expect it to respond to value message
      # @return [Hash{Symbol => SemanticValue}]
      def value
        return widgetry_dispatcher.value unless package.respond_to?(:each_pair)
        Hash[package.map { |key, page_component| [key, page_component.value] }]
      end

      def options
        return widgetry_dispatcher.options unless package.respond_to?(:each_pair)
        Hash[package.map { |key, page_component| [key, page_component.options] }]
      end

      private

      # wrap instantiator with strategy for setting and getting value for underlying object
      # expects that element to respond to set and value
      # @returns [Widgetry::Dispatcher] that responds to set, value, options
      def widgetry_dispatcher
        Widgetry.dispatcher(instantiator)
      end

      # @api private
      # Recursive. Examines each packages and turns each Proc into Component
      def initialize_this package
        if package.kind_of?(Hash)
          Hash[package.map { |key, package| [key, Component.new(package, container)] }]
        elsif package.kind_of?(Component)
          return package.package
        elsif package.kind_of?(Proc)
          package
        else
          fail Exception::Error, "package must be kind of Hash, Component or Watir::Element but I got this: #{package}"
        end
      end
    end

    # Component factory where package is a single watir element wrapper
    # example:
    #   dom(:foo) {text_field(id: 'hello_world')}
    register_dom_factory :dom, Component

    # Component factory where package is a keyed hash of watir element procs. Capture elements that compose this Component
    # example:
    # domkey :foo, switch: -> { checkbox(id: 'feature_checkbox1') }, blurb: -> { textarea(id: 'feature_textarea1') }}
    # builds a Component where package is a hash of two elements with keys :switch and :blurb
    register_domkey_factory :domkey, Component
  end
end