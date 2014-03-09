module Domkey

  module Page

    class PageObject

      attr_accessor :watirproc, :container

      # Compose pageobject where watirproc is either
      # - single element definition or collection of element definitions
      # - and each element definition can be watirproc definition or pageobject
      # and container is either
      # - browser by default
      # - or some other pageobject
      # what is a watirproc? object that responds to call, watirproc or each_pair. In the end a proc
      # waht is a container? it's a proc, a callable object that plays a role of a container for watirproc
      # example: watirproc = lambda {text_field(:id, 'street')}
      # example:
      #   PageObject.new lambda watirproc, lambda {Domkey.browser} #=> single watirproc
      def initialize watirproc, container=lambda { Domkey.browser }
        # single element or hash of elements
        # each element can be an already defined watirproc or watirproc definition
        @container = container
        @watirproc = initialize_this watirproc
      end

      # recursive
      def initialize_this watirproc
        if watirproc.respond_to?(:each_pair)
          #composing this pageobject from several elements
          Hash[watirproc.map { |key, watirproc| [key, PageObject.new(watirproc, container)] }]
        else
          if watirproc.respond_to?(:call)
            # watir object definition at the basic level
            watirproc
          elsif watirproc.respond_to?(:watirproc)
            #pageobject with watirproc, we don't care what container owns it. the new container now owns it
            watirproc.watirproc
          else
            fail Domkey::PageObjectError, "Unable to construct PageObject using definition: #{watirproc}"
          end
        end
      end

      # pageobject is a settable object.
      def set value
        return dom.set(value) unless value.respond_to?(:each_pair)
        value.each_pair { |k, v| watirproc.fetch(k).set(v) }
      end

      def value
        return dom.value unless watirproc.respond_to?(:each_pair)
        Hash[watirproc.map { |key, pageobject| [key, pageobject.value] }]
      end

      # runtime accessors to actual watir elements composing this page object
      # or return the single element
      # what is the element object? just one or a collection?
      def element(key=false)
        #from collection of pairs
        return watirproc.fetch(key).dom if key
        return dom unless watirproc.respond_to?(:each_pair)
        Hash[watirproc.map { |key, watirproc| [key, watirproc.dom] }]
      end

      #private

      # runtime dom element in a specified container
      def dom
        container_at_runtime.instance_exec(&watirproc)
      end

      # container at runtime could be a proc or an actual page object
      # proc we call. pageobject we send dom message to get gack runtime container
      def container_at_runtime
        container.respond_to?(:call) ? container.call : container.dom
      end
    end
  end
end