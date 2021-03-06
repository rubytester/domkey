module Domkey

  module View

    module FactoryMethods
      # class factory methods for custom page_components in the view
    end

    # example:
    # Domkey::View.register_domkey_factory :type_ahead_text_field, TypeAheadTextField
    def self.register_domkey_factory page_component_factory_method, page_component_klass
      FactoryMethods.module_eval %Q{
        def #{page_component_factory_method}(key, hash_of_callable_packages)
          send :define_method, key do
            #{page_component_klass}.new hash_of_callable_packages, watir_container
          end
        end
      }
    end

    # example:
    # Domkey::View.register_dom_factory :select_list, SelectList
    def self.register_dom_factory page_component_factory_method, page_component_klass
      FactoryMethods.module_eval %Q{
        def #{page_component_factory_method}(key, &callable_package)
          send :define_method, key do
            #{page_component_klass}.new callable_package, watir_container
          end
        end
      }
    end


    # module FactoryMethods provides page_components class factory methods in the context of a class that includes Domkey::View
    def self.included(klass)
      klass.extend(FactoryMethods)
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

    # @param [Hash{Symbol => Object}] view payload where Symbol is semantic descriptor for a page_component in the view
    # @param [Symbol] a semantic descriptor identifying a page_component
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
    # for getting value or options for each page_component signaled by symbol
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
