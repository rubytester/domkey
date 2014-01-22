require 'singleton'

module Domkey

  class BrowserSession
    include Singleton
    attr_accessor :browser

    def browser
      @browser ||= Watir::Browser.new
    end
  end
end