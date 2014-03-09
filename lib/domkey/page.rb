module Domkey

  module Page

    module ClassMethods

      # pageobject factory
      def dom(key, &watirproc)
        send :define_method, key do
          PageObject.new watirproc, Proc.new { browser }
        end
      end
    end

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    attr_accessor :browser

    def initialize browser=nil
      @browser = browser
    end

    def browser
      @browser ||= Domkey.browser
    end

  end
end