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
        # For Simple PageObject
        # @param package [Proc(Watir::Element)]
        # @param package [PageObject]
        #
        # For Domain Specific PageObject
        # @param package [Hash{Symbol => Proc(Watir::Element)]
        # @param package [Hash{Symbol => PageObject]
        #
        # @param container [Watir::Element] any elment in browser. Defaults to Domkey.browser (late binding)
        # @param container [Proc(Watir::Element)]
        # @param container [PageObject]
        def initialize package, container=nil
          @container = container
          @package   = initialize_this package
          validate_package_keys
        end

        # @return Watir::Browser
        def browser
          watir_container.browser
        end

        # @return Watir::Element scope for this PageObject
        def watir_container
          container_instantiator
        end

        def container
          @container ||= Domkey.browser
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
          return unless defined? package_keys
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
          if container.kind_of?(Proc)
            container.call
          elsif container.kind_of?(PageObject)
            container.send(:instantiator)
          else
            container
          end
        end
      end
    end
  end
end