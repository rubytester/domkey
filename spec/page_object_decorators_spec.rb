require 'spec_helper'

# domain specific page objects composed from regular page object
# PageObject is a type of object that responds to set and value.
# it is the Role it plays
# DateSelector is a type of decoration for domain specific pageobject
module Domkey

  module View

    #example of specialized domain specific pageobject.
    # behavior of set and value
    class DateSelectorPageObject < PageObject

      def set value
        watirproc.each_pair { |k, po| po.set(value.send(k)) }
      end

      def value
        h = {}
        watirproc.each_pair { |k, po| h[k] = po.value }
        Date.parse "%s/%s/%s" % [h[:year], h[:month], h[:day]]
      end
    end
  end
end


module DomkeySpecHelper

  class CheckboxTextField

    attr_reader :pageobject

    def initialize(pageobject)
      @pageobject = pageobject
    end

    def label
      pageobject.element(:label).text
    end

    def set value
      return pageobject.set switch: false unless value
      if value.kind_of? String
        pageobject.set switch: true, blurb: value
      else
        pageobject.set switch: true
      end
    end

    def value
      if pageobject.element(:switch).set?
        v = pageobject.element(:blurb).value
        v == '' ? true : v
      else
        false
      end
    end
  end


  class DateSelector

    attr_reader :pageobject

    def initialize(pageobject)
      @pageobject = pageobject
    end


    def set value
      pageobject.set day: value.day, month: value.month, year: value.year
    end

    def value
      h = pageobject.value
      Date.parse "%s/%s/%s" % [h[:year], h[:month], h[:day]]
    end

  end

end

describe 'PageObject Decorators' do

  before :all do
    Domkey.browser.goto("file://" + __dir__ + "/html/test.html")
  end

  context 'DateSelector' do

    it 'as pageobject component wrapped by decorator' do

      watir_object = {day:   lambda { text_field(id: 'day_field') },
                      month: lambda { text_field(id: 'month_field') },
                      year:  lambda { text_field(id: 'year_field') }}

      foo = Domkey::View::PageObject.new watir_object
      dmy = DomkeySpecHelper::DateSelector.new foo

      dmy.set Date.today
      dmy.value.should eql Date.today
    end

    it 'inherits from pageobject and overrides set and value' do

      watir_object = {day:   lambda { text_field(id: 'day_field') },
                      month: lambda { text_field(id: 'month_field') },
                      year:  lambda { text_field(id: 'year_field') }}

      #foo = Domkey::Page::PageObject.new watir_object, @container
      dmy          = Domkey::View::DateSelectorPageObject.new watir_object

      dmy.set Date.today
      dmy.value.should eql Date.today
    end

  end


  context 'CheckboxTextField' do


    it 'as pageobject component wrapped by decorator' do

      watir_object = {switch: lambda { checkbox(id: 'feature_checkbox1') },
                      blurb:  lambda { text_field(id: 'feature_textarea1') }}

      #pageobject as component
      foo          = Domkey::View::PageObject.new watir_object

      foo.set switch: true, blurb: 'I am a blurb'
      foo.set switch: false
      foo.set switch: true

      # decorator add specific behavior to set and value methods
      tbcf = DomkeySpecHelper::CheckboxTextField.new foo

      tbcf.set true
      tbcf.set false
      tbcf.set 'hhkhkjhj'

    end

    context 'building array of CheckboxTextFields in the view' do

      it 'algorithm from predictable pattern' do

        #given predictable pattern that singals the presence of pageobjects
        divs = Domkey::View::PageObjectCollection.new lambda { divs(:id, /^feature_/) }

        features = divs.map do |div|

          #the unique identifier shared by all elements composing a PageObject
          id           = div.element.id.split("_").last

          #definiton for each PageObject
          watir_object = {switch: lambda { checkbox(id: "feature_checkbox#{id}") },
                          blurb:  lambda { text_field(id: "feature_textarea#{id}") },
                          label:  lambda { label(for: "feature_checkbox#{id}") }}

          pageobject = Domkey::View::PageObject.new watir_object
          #domain specific pageobject
          DomkeySpecHelper::CheckboxTextField.new(pageobject)
        end

        # array of Domain Specific PageObjects
        features.first.set 'bla'
        features.map { |e| e.value }.should eql ["bla", false]
        features.map { |e| e.pageobject.element(:label).text }.should eql ["Nude Beach", "Golf Course"]
        features.find { |e| e.label == 'Golf Course' }.value.should be_false
      end

      # example of building Domain Specific PageObject
      # from a predictable pattern of element collection on the page
      module CheckboxTextFieldViewFactory

        include Domkey::View

        doms(:feature_divs) { divs(:id, /^feature_/) }

        # returns array of CheckboxTextField pageobjects
        def features
          ids = feature_divs.map { |e| e.element.id.split("_").last }
          ids.map do |i|
            pageobject = PageObject.new switch: -> { checkbox(id: "feature_checkbox#{i}") },
                                        blurb:  -> { text_field(id: "feature_textarea#{i}") },
                                        label:  -> { label(for: "feature_checkbox#{i}") }
            DomkeySpecHelper::CheckboxTextField.new(pageobject)
          end
        end

      end

      # final client view that gets what the factory for pageobjects
      class DomainSpecificPageObjectView
        include CheckboxTextFieldViewFactory

      end

      it 'view factory' do
        view = DomainSpecificPageObjectView.new
        view.features.should have(2).items
        view.features.each { |f| f.set true }
        view.features.each { |f| f.set false }
        view.features.each { |f| f.set "Hello From Feature View" }
      end
    end
  end
end