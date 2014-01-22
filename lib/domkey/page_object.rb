module Domkey

  class PageObject

    attr_accessor :elements, :container

    # Compose page object with dom elements and container which is browser by default
    def initialize elements, container=Domkey.browser
      @elements  = elements
      @container = container
    end

    # set page object
    def set model
      model.each_pair { |k, v| dom(k).set(v) }
    end

    def value model
      Hash[model.map { |k, v| [k, dom(k).value] }]
    end

    private

    # runtime dom element in a specified container
    def dom key
      container.instance_exec(&elements[key])
    end
  end
end