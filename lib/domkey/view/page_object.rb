module Domkey

  module View

    class PageObject

      attr_accessor :watirproc, :container

      # PageObject represents an semantically essential area in a View
      # It is an object that responds to set and value as the main way of sending data to it.
      # it is composed of one or more watir elements.
      # PageObject encapuslates the widgetry of DOM elements to provide semantic interfact to the user of the widgetry
      #
      # Compose PageObject with watirproc and container
      #
      # What is a container? it's a proc, a callable object that plays a role of a container for watirproc widgetry
      # container can be one of:
      # - browser (default)
      # - a pageobject
      #
      # What is watirproc? it's a proc of DOM elements widgetry that can be found inside the container
      # watirproc can be one of the following:
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
      def initialize watirproc, container=lambda { Domkey.browser }
        @container = container
        @watirproc = initialize_this watirproc
      end

      # recursive
      def initialize_this watirproc
        if watirproc.respond_to?(:each_pair) #hash
          Hash[watirproc.map { |key, watirproc| [key, PageObject.new(watirproc, container)] }]
        else
          if watirproc.respond_to?(:call) #proc
            begin
              # peek inside suitcase that is proc. XXX ouch, ugly
              peeked_inside = watirproc.call
            rescue NoMethodError
              return watirproc #suitecase exploded, proc returned
            end
            if peeked_inside.respond_to?(:each_pair) # hash
              return initialize_this peeked_inside
            elsif peeked_inside.respond_to?(:wd) # watir element
              return lambda { peeked_inside }
            elsif peeked_inside.respond_to?(:watirproc) #pageobject
              return peeked_inside.watirproc
            else
              fail Domkey::PageObjectError, "Unable to construct PageObject using definition: #{watirproc}"
            end
          elsif watirproc.respond_to?(:watirproc) #pageobject
            return watirproc.watirproc
          else
            fail Domkey::PageObjectError, "Unable to construct PageObject using definition: #{watirproc}"
          end
        end
      end

      def set value
        return instantiator.set(value) unless value.respond_to?(:each_pair)
        value.each_pair { |k, v| watirproc.fetch(k).set(v) }
      end

      def value
        return instantiator.value unless watirproc.respond_to?(:each_pair)
        Hash[watirproc.map { |key, pageobject| [key, pageobject.value] }]
      end

      # access widgetry of watir elements composing this page object
      def element(key=false)
        return instantiator unless watirproc.respond_to?(:each_pair)
        return watirproc.fetch(key).element if key
        Hash[watirproc.map { |key, watirproc| [key, watirproc.element] }]
      end

      private

      # talk to the browser executor.
      # returns runtime element in a specified container
      # expects that element to respond to set and value
      def instantiator
        container_instantiator.instance_exec(&watirproc)
      end

      # talk to the browser
      # returns runtime container element in a browser/driver
      def container_instantiator
        container.respond_to?(:call) ? container.call : container.send(:instantiator)
      end
    end
  end
end