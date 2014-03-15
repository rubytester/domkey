require 'domkey/view/page_object'
require 'domkey/view/page_object_collection'
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

  end
end