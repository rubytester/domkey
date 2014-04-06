module Domkey

  module View

    class LabelMapper

      # return collection of PageObjects for label locators corresponding to id of each element in a collection
      # @param [Array<PageObject>]
      # @param [PageObjectCollection]
      # @return [Array<PageObject>] where each PageObject is a locator for label for an id of a PageObject passed in parameters
      def self.for collection
        collection.map do |e|
          PageObject.new -> { label(for: e.element.id) }, e.container
        end
      end

      # provide PageObject wrapping label corresponding to id of element in pageobject.
      def self.find pageobject
        PageObject.new -> { label(for: pageobject.element.id) }, pageobject.container
      end
    end
  end
end

