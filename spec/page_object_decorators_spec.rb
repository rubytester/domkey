require 'spec_helper'


describe 'PageObject Decorators' do

  # domain specific page objects composed from regular page object
  # PageObject is a type of object that responds to set and value.
  # it is the Role it plays
  # DateSelector is a type of decoration for domain specific pageobject


  #example of specialized domain specific pageobject.
  # behavior of set and value
  class DateSelectorPageObject < Domkey::View::PageObject

    def set value
      package.each_pair { |k, po| po.set(value.send(k)) }
    end

    def value
      h = {}
      package.each_pair { |k, po| h[k] = po.value }
      Date.parse "%s/%s/%s" % [h[:year], h[:month], h[:day]]
    end
  end


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


  before :all do
    goto_html("test.html")
  end

  context 'DateSelector' do

    it 'as pageobject component wrapped by composite' do

      watir_object = {day:   lambda { text_field(id: 'day_field') },
                      month: lambda { text_field(id: 'month_field') },
                      year:  lambda { text_field(id: 'year_field') }}

      foo = Domkey::View::PageObject.new watir_object
      dmy = DateSelector.new foo

      dmy.set Date.today
      dmy.value.should eql Date.today
    end

    it 'inherits from pageobject and overrides set and value' do

      watir_object = {day:   lambda { text_field(id: 'day_field') },
                      month: lambda { text_field(id: 'month_field') },
                      year:  lambda { text_field(id: 'year_field') }}

      #foo = Domkey::Page::PageObject.new watir_object, @container
      dmy          = DateSelectorPageObject.new watir_object

      dmy.set Date.today
      dmy.value.should eql Date.today
    end

  end

  context 'CheckboxTextField' do

    it 'as pageobject component wrapped by composite' do

      pageobject = Domkey::View::PageObject.new switch: -> { checkbox(id: 'feature_checkbox1') },
                                                blurb:  -> { textarea(id: 'feature_textarea1') }

      # turn switch on and enter text in text area
      pageobject.set switch: true, blurb: 'I am a blurb text after you turn on switch'
      pageobject.set switch: false # => turn switch off, clear textarea blurb entry
      pageobject.set switch: true # => turn switch on

      # wrap with composite and handle specific behavior to set and value
      cbtf = CheckboxTextField.new(pageobject)

      cbtf.set true
      cbtf.set false
      cbtf.set 'Domain Specific Behavior to set value - check checkbox and enter text'
      cbtf.value.should eql('Domain Specific Behavior to set value - check checkbox and enter text')
    end

    context 'building array of CheckboxTextFields in the view' do

      it 'algorithm from predictable pattern' do

        #given predictable pattern that signals the presence of pageobjects
        divs = Domkey::View::PageObjectCollection.new lambda { divs(:id, /^feature_/) }

        features = divs.map do |div|

          #the unique identifier shared by all elements composing a PageObject
          id           = div.element.id.split("_").last

          #definiton for each PageObject
          watir_object = {switch: -> { checkbox(id: "feature_checkbox#{id}") },
                          blurb:  -> { text_field(id: "feature_textarea#{id}") },
                          label:  -> { label(for: "feature_checkbox#{id}") }}

          pageobject = Domkey::View::PageObject.new watir_object
          #domain specific pageobject
          CheckboxTextField.new(pageobject)
        end

        # array of Domain Specific PageObjects
        features.first.set 'bla'
        features.map { |e| e.value }.should eql ["bla", false]
        features.map { |e| e.pageobject.element(:label).text }.should eql ["Enable Checkbox for TextArea", "Golf Course"]
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
            CheckboxTextField.new(pageobject)
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