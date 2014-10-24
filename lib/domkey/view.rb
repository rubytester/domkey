require 'domkey/view/page_object'
require 'domkey/view/page_object_collection'
require 'domkey/view/radio_group'
require 'domkey/view/checkbox_group'
require 'domkey/view/select_list'
require 'domkey/view/binder'

module Domkey

  module View

    # module ClassMethods provides page objects class factory methods in the context of a class that includes Domkey::View
    def self.included(klass)
      klass.extend(ClassMethods)
    end

    # @param [Watir::Element] (false) browser becomes ultimate container for all when no watir container provided
    def initialize watir_container=nil
      @watir_container = watir_container
    end

    # @return [Watir::Browser]
    def browser
      watir_container.browser
    end

    def watir_container
      @watir_container ||= Domkey.browser
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
      binder_class_for_this_view.new(payload: hashified(payload), view: self).value
    end

    def options payload
      binder_class_for_this_view.new(payload: hashified(payload), view: self).options
    end

    private

    # transform possible list of symbols for payload into full hash
    # for getting value or options for each pageobject signaled by symbol
    def hashified(payload)
      case payload
      when Symbol
        {payload => nil}
      when Array
        #array of symbols
        Hash[payload.map { |v| [v, nil] }]
      when Hash
        payload
      end
    end

    def binder_class_for_this_view
      binder_class = self.class.const_defined?(:Binder, false) ? self.class.const_get("Binder") : Binder
    end

  end
end