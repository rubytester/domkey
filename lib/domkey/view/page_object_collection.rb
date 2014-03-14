module Domkey

  module View

    # PageObjectCollection see PageObject for detailes.
    # Compose PageObjectCollection with package and container
    #
    # What is a container? see PageObject container
    #
    # What is package? see PageObject package except the following:
    # package can be one of the following:
    #   - definition of watir elements collection i.e. `-> { text_fields(:class, /^foo/)}`
    #   - a pageobject i.e. previously instantiated definition watir elements collection
    #   - hash where key defines subelement and value a definition or pageobject
    # Usage:
    # Clients would not usually instantate this class.
    # A client class which acts as a View would use a :doms factory method to create PageObjectCollection
    # TODO Example:
    class PageObjectCollection

      include PageObject::WidgetryPackage
      include Enumerable

      # @return [PageObject, Hash{Symbol => PageObjectCollection}]
      def each(&blk)
        if package.respond_to?(:each_pair)
          package.map { |k, v| [k, PageObjectCollection.new(lambda { v }, @container)] }.each { |k, v| yield Hash[k, v] }
        else
          instantiator.each { |e| yield PageObject.new(lambda { e }, @container) }
        end
      end

      # @param [Fixnum]
      # @return [PageObject, Hash{Symbol => PageObjectCollection}]
      def [] idx
        to_a[idx]
      end

      alias_method :size, :count

      private

      # @api private
      # Recursive. Examines each packages and turns each Proc into PageObject
      def initialize_this package
        if package.respond_to?(:each_pair) #hash
          Hash[package.map { |key, package| [key, PageObjectCollection.new(package, container)] }]
        else
          if package.respond_to?(:call) #proc
            package
          elsif package.respond_to?(:package)
            package.package
          else
            fail Exception::Error, "package must be kind of hash, watirelement or pageobject but I got this: #{package}"
          end
        end
      end
    end
  end
end
