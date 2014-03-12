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

      # pageobject is a settable object.
      def set value
        return instantiator.set(value) unless value.respond_to?(:each_pair)
        value.each_pair { |k, v| watirproc.fetch(k).set(v) }
      end

      def value
        return instantiator.value unless watirproc.respond_to?(:each_pair)
        Hash[watirproc.map { |key, pageobject| [key, pageobject.value] }]
      end

      # runtime accessors to actual watir elements composing this page object
      # or return the single element
      # what is the element object? just one or a collection?
      def element(key=false)
        #from collection of pairs
        return watirproc.fetch(key).instantiator if key
        return instantiator unless watirproc.respond_to?(:each_pair)
        Hash[watirproc.map { |key, watirproc| [key, watirproc.instantiator] }]
      end

      #private

      # runtime dom element in a specified container or collection of dom elements
      def instantiator
        container_at_runtime.instance_exec(&watirproc)
      end

      # container at runtime could be a proc or an actual page object
      # proc we call. pageobject we send dom message to get gack runtime container
      def container_at_runtime
        container.respond_to?(:call) ? container.call : container.instantiator
      end
    end
  end
end