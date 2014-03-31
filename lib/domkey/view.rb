require 'domkey/view/page_object'
require 'domkey/view/page_object_collection'
require 'domkey/view/radio_group'
require 'domkey/view/checkbox_group'
require 'domkey/view/cargo'

module Domkey

  module View

    module ClassMethods

      # PageObjectCollection factory
      def doms(key, &package)
        send :define_method, key do
          PageObjectCollection.new package, Proc.new { browser }
        end
      end

      # PageObject factory
      def dom(key, &package)
        send :define_method, key do
          PageObject.new package, Proc.new { browser }
        end
      end

      # build Cargo with model and view
      # @return [Domkey::View::Cargo]
      def cargo model, browser: nil
        Cargo.new model: model, view: self.new(browser)
      end

    end

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    attr_accessor :browser

    # @param [Watir::Browser] (false)
    def initialize browser=nil
      @browser = browser
    end

    # browser for this view.
    # if View was initialized without a browser then default Domkey.browser is provided
    # @return [Watir::Browser]
    def browser
      @browser ||= Domkey.browser
    end

    def set value
      Cargo.new(model: value, view: self).set
    end

    # @param [Hash{Symbol => Object}] view data where Symbol is semantic descriptor for a pageobject in the view
    # @param [Symbol] for one pageobject
    # @param [Array<Symbol>] for array of pageobjects
    #
    # @return [Hash{Symbol => Object}] data from the view
    def value value
      # transform value into hash
      value = case value
              when Symbol
                {value => nil}
              when Array
                #array of symbols
                Hash[value.map { |v| [v, nil] }]
              when Hash
                value
              end
      Cargo.new(model: value, view: self).value
    end

  end
end