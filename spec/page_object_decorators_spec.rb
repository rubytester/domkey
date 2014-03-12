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
    @container = lambda { Domkey.browser }
  end

  context 'DateSelector' do

    it 'compose' do

      watir_object = {day:   lambda { text_field(id: 'day_field') },
                      month: lambda { text_field(id: 'month_field') },
                      year:  lambda { text_field(id: 'year_field') }}

      foo = Domkey::View::PageObject.new watir_object, @container
      dmy = DomkeySpecHelper::DateSelector.new foo

      dmy.set Date.today
      dmy.value.should eql Date.today
    end

    it 'smoosh' do

      watir_object = {day:   lambda { text_field(id: 'day_field') },
                      month: lambda { text_field(id: 'month_field') },
                      year:  lambda { text_field(id: 'year_field') }}

      #foo = Domkey::Page::PageObject.new watir_object, @container
      dmy          = Domkey::View::DateSelectorPageObject.new watir_object, @container

      dmy.set Date.today
      pp dmy.value #.should eql Date.today
    end


  end


  context 'CheckboxTextField' do


    it 'compose' do

      watir_object = {switch: lambda { checkbox(id: 'feature_checkbox1') },
                      blurb:  lambda { text_field(id: 'feature_textarea1') }}

      foo  = Domkey::View::PageObject.new watir_object, @container

      #foo.set switch: true, blurb: 'I am a blurb'
      #foo.set switch: true
      #foo.set switch: false

      tbcf = DomkeySpecHelper::CheckboxTextField.new foo

      tbcf.set true
      tbcf.set false
      tbcf.set 'hhkhkjhj'

    end

    it 'collection' do

      #predictable pattern that singals the presence of pageobjects
      foo = lambda { divs(:id, /^feature_/) }

      divs = Domkey::View::PageObjectCollection.new foo

      features = divs.map do |div|

        id = div.element.id.split("_").last

        watir_object = {switch: lambda { checkbox(id: "feature_checkbox#{id}") },
                        blurb:  lambda { text_field(id: "feature_textarea#{id}") },
                        label:  lambda { label(for: "feature_checkbox#{id}") }}

        foo = Domkey::View::PageObject.new watir_object, @container

        #foo.set switch: true, blurb: 'I am a blurb'
        #foo.set switch: true
        #foo.set switch: false

        DomkeySpecHelper::CheckboxTextField.new foo
      end

      features.first.set 'bla'
      #features[1].set true
      features.map { |e| e.value }.should eql ["bla", false]
      features.map { |e| e.pageobject.element(:label).text }.should eql ["Nude Beach", "Golf Course"]

      features.find { |e| e.label == 'Golf Course' }.value.should be_false
    end

  end
end