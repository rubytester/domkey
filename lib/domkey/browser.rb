require 'watir-webdriver'
module Domkey

  module Browser

    class << self

      # new browser comes from registered factory
      def new
        if @browser_factory
          @browser_factory.call
        else
          fail Domkey::Exception::NotImplementedError, 'expected a default factory for getting new browser session. please define'
        end

      end

      # register default way to get new browser session
      # example: remote chrome session
      #     Domkey::Browser.factory do
      #       Watir::Browser.new :chrome, :url => 'http://localhost:4444/wd/hub'
      #     end
      #
      # example: local default browser
      #     Domkey::Browser.factory do
      #       Watir::Browser.new
      #     end
      #
      def factory(&blk)
        @browser_factory = blk
      end

    end
  end
end