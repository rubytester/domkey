require 'domkey/view/page_object'
require 'domkey/view/page_object_collection'
require 'domkey/view/radio_group'
require 'domkey/view/checkbox_group'
require 'domkey/view/select_list'
require 'domkey/view/binder'

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

      # build Binder with model and view
      # @return [Domkey::View::Binder]
      # @return [Self::Binder] if Binder defined for the View Class
      def binder payload, browser: nil
        binder_class = self.const_defined?(:Binder, false) ? self.const_get("Binder") : Binder
        binder_class.new payload: payload, view: self.new(browser)
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

    def set payload
      binder_class_for_this_view.new(payload: payload, view: self).set
    end

    # @param [Hash{Symbol => Object}] view payload where Symbol is semantic descriptor for a pageobject in the view
    # @param [Symbol] a semantic descriptor identifying a pageobject
    # @param [Array<Symbol>] for array of semantic descriptors
    #
    # @return [Hash{Symbol => Object}] payload from the view
    def value payload
      # transform value into hash
      payload = case payload
              when Symbol
                {payload => nil}
              when Array
                #array of symbols
                Hash[payload.map { |v| [v, nil] }]
              when Hash
                payload
                end
      binder_class_for_this_view.new(payload: payload, view: self).value
    end

    private

    def binder_class_for_this_view
      binder_class = self.class.const_defined?(:Binder, false) ? self.class.const_get("Binder") : Binder
    end

  end
end