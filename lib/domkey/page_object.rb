module Domkey

  class PageObject

    attr_accessor :elements, :container

    # Compose page object with dom elements and container which is browser by default
    # elements is hash of procs. key in hash corresponds to key in model
    def initialize pageobjects, container=lambda { Domkey.browser }
      @pageobjects = pageobjects
      @container   = container
    end

    # set page object
    def set model
      model.each_pair { |k, v| dom(k).set(v) }
    end

    def value
      Hash[@pageobjects.map { |k, _| [k, dom(k).value] }]
    end

    # runtime accessors to actual watir elements composing this page object
    def elements
      Hash[@pageobjects.map { |k, v| [k, dom(k)] }]
    end

    private

    # runtime dom element in a specified container
    def dom key
      container.call.instance_exec(&@pageobjects[key])
    end
  end
end