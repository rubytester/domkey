module Domkey

  module View

    class LabelMapper

      # return collection of Components for label locators corresponding to id of each element in a collection
      # @param [Array<Component>]
      # @param [ComponentCollection]
      # @return [Array<Component>] where each Component is a locator for label for an id of a Component passed in parameters
      def self.for collection
        collection.map do |e|
          Component.new -> { label(for: e.element.id) }, e.container
        end
      end

      # provide Component wrapping label corresponding to id of element in page_component.
      def self.find page_component
        Component.new -> { label(for: page_component.element.id) }, page_component.container
      end
    end
  end
end

