require 'spec_helper'

describe 'PageObject Decorators' do

  # domain specific page objects composed from regular page object
  # PageObject is a type of object that responds to set and value.
  # it is the Role it plays
  # DateSelector is a type of decoration for domain specific pageobject


  #example of specialized domain specific pageobject.
  # behavior of set and value
  class DateSelectorPageObject < Domkey::View::PageObject

    package_keys :year, :month, :day

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


  before :each do
    goto_html("test.html")
  end

  context 'DateSelector' do

    it 'as pageobject component wrapped by composite' do

      hash = {day:   -> { text_field(id: 'day_field') },
              month: -> { text_field(id: 'month_field') },
              year:  -> { text_field(id: 'year_field') }}

      # Example of poro decorator wrapping pageobject composed of hashed keys
      dmy  = DateSelector.new(Domkey::View::PageObject.new hash, -> { Domkey.browser })

      dmy.set Date.today
      expect(dmy.value).to eq Date.today
    end

    it 'inherits from pageobject and overrides set and value' do

      hash = {day:   -> { text_field(id: 'day_field') },
              month: -> { text_field(id: 'month_field') },
              year:  -> { text_field(id: 'year_field') }}

      #example of subclassing PageObject with override set and value
      dmy  = DateSelectorPageObject.new hash, -> { Domkey.browser }

      dmy.set Date.today
      expect(dmy.value).to eq Date.today
    end

  end

  context 'CheckboxTextField' do

    it 'as pageobject component wrapped by composite' do

      hash       = {switch: -> { checkbox(id: 'feature_checkbox1') }, blurb: -> { textarea(id: 'feature_textarea1') }}
      pageobject = Domkey::View::PageObject.new hash, -> { Domkey.browser }

      # turn switch on and enter text in text area
      pageobject.set switch: true, blurb: 'I am a blurb text after you turn on switch'
      pageobject.set switch: false # => turn switch off, clear textarea blurb entry
      pageobject.set switch: true # => turn switch on

      # wrap with composite and handle specific behavior to set and value
      cbtf = CheckboxTextField.new(pageobject)

      cbtf.set true
      cbtf.set false
      cbtf.set 'Domain Specific Behavior to set value - check checkbox and enter text'
      expect(cbtf.value).to eq 'Domain Specific Behavior to set value - check checkbox and enter text'
    end

    context 'building array of CheckboxTextFields in the view' do

      it 'algorithm from predictable pattern' do

        #given predictable pattern that signals the presence of pageobjects
        divs = Domkey::View::PageObjectCollection.new -> { divs(:id, /^feature_/) }, -> { Domkey.browser }

        features = divs.map do |div|

          #the unique identifier shared by all elements composing a PageObject
          id   = div.element.id.split("_").last

          #definiton for each PageObject
          hash = {switch: -> { checkbox(id: "feature_checkbox#{id}") },
                  blurb:  -> { text_field(id: "feature_textarea#{id}") },
                  label:  -> { label(for: "feature_checkbox#{id}") }}

          pageobject = Domkey::View::PageObject.new hash, -> { Domkey.browser }
          #domain specific pageobject decorator
          CheckboxTextField.new(pageobject)
        end

        # array of Domain Specific PageObjects
        features.first.set 'bla'
        expect(features.map { |e| e.value }).to eq ["bla", false]
        expect(features.map { |e| e.pageobject.element(:label).text }).to eq ["Enable Checkbox for TextArea", "Golf Course"]
        expect(features.find { |e| e.label == 'Golf Course' }.value).to be_false
      end

      # example of building Domain Specific PageObject
      # from a predictable pattern of element collection on the page
      module CheckboxTextFieldViewFactory

        include Domkey::View

        # collection
        doms(:feature_divs) { divs(:id, /^feature_/) }

        # returns array of CheckboxTextField pageobjects
        # as you see this is a collection of custom pageobjects accessible with method :features
        # all objects are created at runtime.
        def features
          ids = feature_divs.map { |e| e.element.id.split("_").last }
          ids.map do |i|
            hash       = {
                switch: -> { checkbox(id: "feature_checkbox#{i}") },
                blurb:  -> { text_field(id: "feature_textarea#{i}") },
                label:  -> { label(for: "feature_checkbox#{i}") }
            }
            # generic domkey pageobject but not a method in the view
            pageobject = PageObject.new hash, -> { watir_container }
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

        expect(view.features).to have(2).items
        view.features.each { |f| f.set true }
        expect(view.features.map { |e| e.value }).to eq ["CheckboxTextField 1", "CheckboxTextField 2"]

        view.features.each { |f| f.set false }
        expect(view.features.map { |e| e.value }).to eq [false, false]

        view.features.each { |f| f.set "Hello From Feature View" }
        view.features.each do |f|
          expect(f.value).to eq 'Hello From Feature View'
        end

      end
    end
  end
end