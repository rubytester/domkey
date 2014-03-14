module Domkey

  module View

    class PageObject

      # @api private
      module WidgetryPackage

        attr_accessor :package, :container

        def initialize package, container=lambda { Domkey.browser }
          @container = container
          @package   = initialize_this package
        end

        # access widgetry of watir elements composing this page object
        def element(key=false)
          return instantiator unless package.respond_to?(:each_pair)
          return package.fetch(key).element if key
          Hash[package.map { |key, package| [key, package.element] }]
        end

        private

        # talk to the browser executor.
        # returns runtime element in a specified container
        # expects that element to respond to set and value
        def instantiator
          container_instantiator.instance_exec(&package)
        end

        # talk to the browser
        # returns runtime container element in a browser/driver
        def container_instantiator
          container.respond_to?(:call) ? container.call : container.send(:instantiator)
        end
      end

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
      include WidgetryPackage

      def set value
        return instantiator.set(value) unless value.respond_to?(:each_pair)
        value.each_pair { |k, v| package.fetch(k).set(v) }
      end

      def value
        return instantiator.value unless package.respond_to?(:each_pair)
        Hash[package.map { |key, pageobject| [key, pageobject.value] }]
      end

      private

      # recursive
      def initialize_this package
        if package.respond_to?(:each_pair) #hash
          Hash[package.map { |key, package| [key, PageObject.new(package, container)] }]
        else
          if package.respond_to?(:call) #proc
            begin
              # peek inside suitcase that is proc. XXX ouch, ugly
              peeked_inside = package.call
            rescue NoMethodError
              return package #suitecase exploded, proc returned
            end
            if peeked_inside.respond_to?(:each_pair) # hash
              return initialize_this peeked_inside
            elsif peeked_inside.respond_to?(:wd) # watir element
              return lambda { peeked_inside }
            elsif peeked_inside.respond_to?(:package) #pageobject
              return peeked_inside.package
            else
              fail Exception::Error, "package must be kind of hash, watirelement or pageobject but I got this: #{package}"
            end
          elsif package.respond_to?(:package) #pageobject
            return package.package
          else
            fail Exception::Error, "package must be kind of hash, watirelement or pageobject but I got this: #{package}"
          end
        end
      end
    end
  end
end