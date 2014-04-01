module Domkey

  module View

    # return collection of PageObjects for label locators corresponding to id of each element in a collection
    class LabelMapper
      # @param [Array<PageObject>]
      # @param [PageObjectCollection]
      # @return [Array<PageObject>] where each PageObject is a locator for label for an id of a PageObject passed in parameters
      def self.for collection
        collection.map do |e|
          PageObject.new -> { label(for: e.element.id) }, e.container
        end
      end
    end
  end
end

