require 'singleton'

module Domkey

  class BrowserSession
    include Singleton
    attr_accessor :browser

    def browser
      return @browser if (@browser && @browser.exist?)
      @browser = Watir::Browser.new
    end
  end
end