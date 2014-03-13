module Domkey

  module View

    class PageObjectCollection
      include Enumerable

      attr_accessor :watirproc, :container

      # PageObjectCollection see PageObject for detailes.
      # Compose PageObjectCollection with watirproc and container
      #
      # What is a container? see PageObject container
      #
      # What is watirproc? see PageObject watirproc except the following:
      # watirproc can be one of the following:
      #   - definition of watir elements collection i.e. `-> { text_fields(:class, /^foo/)}`
      #   - a pageobject i.e. previously instantiated definition watir elements collection
      #   - hash where key defines subelement and value a definition or pageobject
      # Usage:
      # Clients would not usually instantate this class.
      # A client class which acts as a View would use a :doms factory method to create PageObjectCollection
      # Example:
      #
      def initialize watirproc, container=lambda { Domkey.browser }
        @container = container
        @watirproc = initialize_this watirproc
      end

      def element(key=false)
        return instantiator unless watirproc.respond_to?(:each_pair)
        return watirproc.fetch(key).element if key
        Hash[watirproc.map { |key, watirproc| [key, watirproc.element] }]
      end

      def each(&blk)
        if watirproc.respond_to?(:each_pair)
          watirproc.map { |k, v| [k, PageObjectCollection.new(lambda { v }, @container)] }.each { |k, v| yield Hash[k, v] }
        else
          instantiator.each { |e| yield PageObject.new(lambda { e }, @container) }
        end
      end

      def [] idx
        to_a[idx]
      end

      alias_method :size, :count

      private

      # --
      # recursive
      def initialize_this watirproc
        if watirproc.respond_to?(:each_pair) #hash
          Hash[watirproc.map { |key, watirproc| [key, PageObjectCollection.new(watirproc, container)] }]
        else
          if watirproc.respond_to?(:call) #proc
            watirproc
          elsif watirproc.respond_to?(:watirproc)
            watirproc.watirproc
          else
            fail Exception::Error, "watirproc must be kind of hash, watirelement or pageobject but I got this: #{watirproc}"
          end
        end
      end

      def instantiator
        container_at_runtime.instance_exec(&watirproc)
      end

      def container_at_runtime
        container.respond_to?(:call) ? container.call : container.send(:instantiator)
      end

    end
  end
end
