module Domkey

  class PageObject

    attr_accessor :elements, :container

    # Compose page object with dom elements and container which is browser by default
    # elements is hash of procs. key in hash corresponds to key in model
    def initialize elements, container=lambda { Domkey.browser }
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
      container.call.instance_exec(&elements[key])
    end
  end
end