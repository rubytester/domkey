module Domkey
  module View
    module Widgetry

      module Package

        attr_accessor :package, :container

        module ClassMethods

          # optionally when building a new Domain Specific PageObject
          # validate your package hash kesy used in initializing your pageobject
          # example:
          #     class MyCustomThing < Domkey::View::PageObject
          #       package_keys :foo, :bar
          #     end
          #     MyCustomThink.new package, container
          # when you instantiate your pageobject it will validate your package is a hash with keys :foo, :bar
          def package_keys *keys
            send :define_method, :package_keys do
              keys
            end
          end
        end

        def self.included(klass)
          klass.extend(ClassMethods)
        end

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
          validate_package_keys
        end

        # access widgetry of watir elements composing this page object
        # @param [Symbol] (false)
        # @return [Hash{Symbol => WebdriverElement}]
        # @return [Element] raw element, i.e. Watir::Select, Watir::CheckBox (not wrapped with Dispatcher strategy)
        def element(key=false)
          return instantiator unless package.respond_to?(:each_pair)
          return package.fetch(key).element if key
          Hash[package.map { |key, package| [key, package.element] }]
        end

        private

        def validate_package_keys
          return unless respond_to?(:package_keys)
          fail ArgumentError, "Package must be a kind of hash" unless package.respond_to?(:keys)
          return if (package_keys - package.keys).empty?
          fail ArgumentError, "Package must supply keys: #{package_keys.inspect} but got: #{package.keys.inspect}"
        end

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
end