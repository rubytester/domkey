module Domkey

  class PageObject

    attr_accessor :elements, :container

    # Compose page object with dom elements and container which is browser by default
    # elements is hash of procs. key in hash corresponds to key in model
    def initialize pageobjects, container=lambda { Domkey.browser }
      # single element or has of elements
      # each element can be an already defined pageobject or watir_object definition
      @pageobjects = initialize_them pageobjects
      @container   = container
    end

    def single_object
      :page_object_single_object_defined
    end

    def initialize_them pageobjects
      return pageobjects if pageobjects.respond_to?(:each_pair)
      {single_object => pageobjects}
    end

    # set page object
    def set model
      return dom(single_object).set(model) unless model.respond_to?(:each_pair)
      model.each_pair { |k, v| dom(k).set(v) }
    end

    def value
      return dom(single_object).value if @pageobjects[single_object]
      Hash[@pageobjects.map { |k, _| [k, dom(k).value] }]
    end

    # runtime accessors to actual watir elements composing this page object
    # or return the single element
    def elements
      objects = Hash[@pageobjects.map { |k, v| [k, dom(k)] }]
      objects[single_object] || objects
    end

    private

    # runtime dom element in a specified container
    def dom key
      container.call.instance_exec(&@pageobjects[key])
    end
  end
end