module Domkey
  module View
    module Widgetry

      module Package

        attr_accessor :package, :container

        module ClassMethods

          # optionally when building a new Domain Specific Component
          # validate your package hash keys used in initializing your page_component
          # example:
          #     class MyCustomThing < Domkey::View::Component
          #       package_keys :foo, :bar
          #     end
          #     MyCustomThink.new package, container
          # when you instantiate your page_component it will validate your package is a hash with keys :foo, :bar
          def package_keys *keys
            send :define_method, :package_keys do
              keys
            end
          end
        end

        def self.included(klass)
          klass.extend(ClassMethods)
        end

        # initialize Component or ComponentCollection
        # for Component expects WebdriverElement a single element definition i.e text_field, checkbox
        # for ComponentCollection expects WebdriverElement a collection definition i.e. text_fields, checkboxes
        # For Simple Component
        # @param package [Proc(Watir::Element)]
        # @param package [Component]
        #
        # For Domain Specific Component
        # @param package [Hash{Symbol => Proc(Watir::Element)]
        # @param package [Hash{Symbol => Component]
        #
        # @param container [Watir::Element] any elment in browser. Defaults to Domkey.browser (late binding)
        # @param container [Proc(Watir::Element)]
        # @param container [Component]
        def initialize package, container=nil
          @container = container
          @package   = initialize_this package
          validate_package_keys
        end

        # @return Watir::Browser
        def browser
          watir_container.browser
        end

        # @return Watir::Element scope for this Component
        def watir_container
          container_instantiator
        end

        def container
          @container ||= Domkey.browser
        end

        # access widgetry of watir elements composing this page_component
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
          elsif container.kind_of?(Component)
            container.__send__(:instantiator)
          else
            container
          end
        end
      end
    end
  end
end