module Domkey

  module View

    module WidgetryPackage

      attr_accessor :package, :container

      # initialize PageObject or PageObjectCollection
      # for PageObject expects WebdriverElement a single element definition i.e text_field, checkbox
      # for PageObjectCollection expects WebdriverElement a collection definition i.e. text_fields, checkboxes
      # @param package [Proc(WebdriverElement)]
      # @param package [PageObject]
      # @param package [Hash{Symbol => Proc(WebdriverElement)]
      # @param package [Hash{Symbol => PageObject]
      def initialize package, container=lambda { Domkey.browser }
        @container = container
        @package   = initialize_this package
      end

      # access widgetry of watir elements composing this page object
      # @param [Symbol] (false)
      # @return [Hash{Symbol => WebdriverElement}]
      # @return [WebdriverElement]
      def element(key=false)
        return instantiator unless package.respond_to?(:each_pair)
        return package.fetch(key).element if key
        Hash[package.map { |key, package| [key, package.element] }]
      end

      private

      # talks to the browser
      # returns runtime element in a specified container
      # @return [WebdriverElement]
      def instantiator
        container_instantiator.instance_exec(&package)
      end

      # talks to the browser
      # returns runtime container element in a browser/driver
      # @return [WebdriverElement]
      def container_instantiator
        container.respond_to?(:call) ? container.call : container.send(:instantiator)
      end
    end
  end
end