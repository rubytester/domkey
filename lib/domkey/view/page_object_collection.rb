module Domkey

  module View

    class PageObjectCollection
      include Enumerable

      attr_accessor :watirproc, :container

      # watirproc is either
      #   a proc that defines watir collection i.e lambda {class: /^street/}
      #   or a hash where value in each key is a proc
      # basically some widgetry to interaction with watir collection
      def initialize watirproc, container=lambda { Domkey.browser }
        @container = container
        @watirproc = initialize_this watirproc
      end

      # --
      # recursive
      def initialize_this watirproc
        if watirproc.respond_to?(:each_pair)
          Hash[watirproc.map { |key, watirproc| [key, PageObjectCollection.new(watirproc, container)] }]
        else
          if watirproc.respond_to?(:call)
            watirproc
          elsif watirproc.respond_to?(:watirproc)
            watirproc.watirproc
          else
            fail Domkey::PageObjectError, "Unable to construct PageObjectCollection using definition: #{watirproc}"
          end
        end
      end

      def element(key=false)
        return watirproc.fetch(key).instantiator if key
        return instantiator unless watirproc.respond_to?(:each_pair)
        Hash[watirproc.map { |key, watirproc| [key, watirproc.instantiator] }]
      end

      def each(&blk)
        if watirproc.respond_to?(:each_pair)
          watirproc.map { |k, v| [k, PageObjectCollection.new(lambda { v }, @container)] }.each { |k, v| yield Hash[k, v] }
        else
          instantiator.each { |e| yield PageObject.new(lambda { e }, @container) }
        end
      end

      # runtime dom element in a specified container or collection of dom elements
      def instantiator
        container_at_runtime.instance_exec(&watirproc)
      end

      # container at runtime could be a proc or an actual page object
      # proc we call. pageobject we send dom message to get gack runtime container
      def container_at_runtime
        container.respond_to?(:call) ? container.call : container.instantiator
      end

      def [] idx
        to_a[idx]
      end

      alias_method :size, :count

    end
  end
end
