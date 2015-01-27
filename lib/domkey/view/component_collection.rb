module Domkey

  module View

    # ComponentCollection see Component for detailes.
    # Compose ComponentCollection with package and container
    #
    # What is a container? see Component container
    #
    # What is package? see Component package except the following:
    # package can be one of the following:
    #   - definition of watir elements collection i.e. `-> { text_fields(:class, /^foo/)}`
    #   - a page_component i.e. previously instantiated definition watir elements collection
    #   - hash where key defines subelement and value a definition or page_component
    # Usage:
    # Clients would not usually instantate this class.
    # A client class which acts as a View would use a :doms factory method to create ComponentCollection
    # TODO Example:
    class ComponentCollection

      include Widgetry::Package
      include Enumerable

      # @return [Component, Hash{Symbol => ComponentCollection}]
      def each(&blk)
        if package.respond_to?(:each_pair)
          package.map { |k, v| [k, ComponentCollection.new(lambda { v }, @container)] }.each { |k, v| yield Hash[k, v] }
        else
          instantiator.each { |e| yield Component.new(lambda { e }, @container) }
        end
      end

      # @param [Fixnum]
      # @return [Component, Hash{Symbol => ComponentCollection}]
      def [] idx
        to_a[idx]
      end

      alias_method :size, :count

      private

      # @api private
      # Recursive. Examines each packages and turns each Proc into Component
      def initialize_this package
        if package.respond_to?(:each_pair) #hash
          Hash[package.map { |key, package| [key, ComponentCollection.new(package, container)] }]
        else
          if package.respond_to?(:call) #proc
            package
          elsif package.respond_to?(:package)
            package.package
          else
            fail Exception::Error, "package must be kind of hash, watirelement or page_component but I got this: #{package}"
          end
        end
      end
    end

    # ComponentCollection factory where package is a watir elements collection
    # example:
    # doms(:streets) { text_fields(class: 'street1') }
    register_dom_factory :doms, ComponentCollection
  end
end
