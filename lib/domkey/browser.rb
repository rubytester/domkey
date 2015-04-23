require 'watir-webdriver'
module Domkey

  module Browser

    class << self

      # new browser comes from registered factory
      def new
        if @browser_factory
          @browser_factory.factory
        else
          Watir::Browser.new
        end

      end

      # register object that creates new browser session
      # object must respond to :factory method
      #     Domkey::Browser.factory = obj
      #
      def factory= object_responds_to_factory
        @browser_factory = object_responds_to_factory
      end

    end

    class Factory
      def factory
        raise NotImplementedError, "Responsibility of a subclass"
      end
    end
  end
end