require 'spec_helper'

# domain specific page objects composed from regular page object
# PageObject is a type of object that responds to set and value.
# it is the Role it plays
# DateSelector is a type of decoration for domain specific pageobject
module DomkeySpecHelper

  class TextboxCheckField

    def initialize(page_object)
      @po = page_object
    end

    def set value
      return @po.set switch: false unless value
      if value.kind_of? String
        @po.set switch: true, blurb: value
      else
        @po.set switch: true
      end
    end

  end


  class DateSelector

    def initialize page_object
      @po = page_object
    end

    def set value
      @po.set day: value.day, month: value.month, year: value.year
    end

    def value
      h = @po.value
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

      foo = Domkey::Page::PageObject.new watir_object, @container
      dmy = DomkeySpecHelper::DateSelector.new foo

      dmy.set Date.today
      dmy.value.should eql Date.today
    end

  end


  context 'CheckboxTextField' do


    it 'compose' do

      watir_object = {switch: lambda { checkbox(id: 'feature_checkbox1') },
                      blurb:  lambda { text_field(id: 'feature_textarea1') }}

      foo  = Domkey::Page::PageObject.new watir_object, @container

      #foo.set switch: true, blurb: 'I am a blurb'
      #foo.set switch: true
      #foo.set switch: false

      tbcf = DomkeySpecHelper::TextboxCheckField.new foo

      tbcf.set true
      tbcf.set false
      tbcf.set 'hhkhkjhj'

    end

  end
end