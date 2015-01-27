require 'spec_helper'

describe 'Component Decorators' do

  # example of specialized domain specific page_component.
  # behavior of set and value
  class DateSelectorComponent < Domkey::View::Component

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


  # Plain Ruby Decorator Example
  class CheckboxTextField

    attr_reader :page_component

    def initialize(page_component)
      @page_component = page_component
    end

    def label
      page_component.element(:label).text
    end

    def set value
      return page_component.set switch: false unless value
      if value.kind_of? String
        page_component.set switch: true, blurb: value
      else
        page_component.set switch: true
      end
    end

    def value
      if page_component.element(:switch).set?
        v = page_component.element(:blurb).value
        v == '' ? true : v
      else
        false
      end
    end
  end


  # Plain Ruby Decorator Example
  class DateSelector

    attr_reader :page_component

    def initialize(page_component)
      @page_component = page_component
    end


    def set value
      page_component.set day: value.day, month: value.month, year: value.year
    end

    def value
      h = page_component.value
      Date.parse "%s/%s/%s" % [h[:year], h[:month], h[:day]]
    end
  end


  before :each do
    goto_html("test.html")
  end

  context 'DateSelector' do

    it 'example poro decorator wrapping page_component composed of hashed keys' do

      hash = {day:   -> { text_field(id: 'day_field') },
              month: -> { text_field(id: 'month_field') },
              year:  -> { text_field(id: 'year_field') }}

      dmy = DateSelector.new Domkey::View::Component.new(hash)

      dmy.set Date.today
      expect(dmy.value).to eq Date.today
    end

    it 'example of subclass which overrides set and value' do

      hash = {day:   -> { text_field(id: 'day_field') },
              month: -> { text_field(id: 'month_field') },
              year:  -> { text_field(id: 'year_field') }}

      dmy = DateSelectorComponent.new hash

      dmy.set Date.today
      expect(dmy.value).to eq Date.today
    end

  end

  context 'CheckboxTextField' do

    it 'example domain specific 3 states for setting a component' do

      hash           = {switch: -> { checkbox(id: 'feature_checkbox1') },
                        blurb:  -> { textarea(id: 'feature_textarea1') }}
      page_component = Domkey::View::Component.new hash

      # turn switch on and enter text in text area
      page_component.set switch: true, blurb: 'I am a blurb text after you turn on switch'

      # turn switch off, clear textarea blurb entry
      page_component.set switch: false

      # only turn switch on and do not enter any text
      page_component.set switch: true

      # wrap with composite and handle specific behavior to set and value
      cbtf = CheckboxTextField.new(page_component)

      cbtf.set true
      cbtf.set false
      cbtf.set 'Domain Specific Behavior to set value - check checkbox and enter text'
      expect(cbtf.value).to eq 'Domain Specific Behavior to set value - check checkbox and enter text'
    end

    context 'dynamically building collection of CheckboxTextFields' do

      it 'algorithm from predictable pattern' do

        #given predictable pattern that signals the presence of page_components
        divs = Domkey::View::ComponentCollection.new -> { divs(:id, /^feature_/) }

        features = divs.map do |div|

          #the unique identifier shared by all elements composing a Component
          id   = div.element.id.split("_").last

          #definiton for each Component
          hash = {switch: -> { checkbox(id: "feature_checkbox#{id}") },
                  blurb:  -> { text_field(id: "feature_textarea#{id}") },
                  label:  -> { label(for: "feature_checkbox#{id}") }}

          page_component = Domkey::View::Component.new hash
          #domain specific page_component decorator
          CheckboxTextField.new(page_component)
        end

        # array of Domain Specific Components
        features.first.set 'bla'
        expect(features.map { |e| e.value }).to eq ["bla", false]
        expect(features.map { |e| e.page_component.element(:label).text }).to eq ["Enable Checkbox for TextArea", "Golf Course"]
        expect(features.find { |e| e.label == 'Golf Course' }.value).to be_falsey
      end

      # example of building Domain Specific Component
      # from a predictable pattern of element collection on the page
      module CheckboxTextFieldViewFactory

        include Domkey::View

        # collection
        doms(:feature_divs) { divs(:id, /^feature_/) }

        # returns array of CheckboxTextField page_components
        # as you see this is a collection of custom page_components accessible with method :features
        # all objects are created at runtime.
        def features
          ids = feature_divs.map { |e| e.element.id.split("_").last }
          ids.map do |i|
            hash           = {
                switch: -> { checkbox(id: "feature_checkbox#{i}") },
                blurb:  -> { text_field(id: "feature_textarea#{i}") },
                label:  -> { label(for: "feature_checkbox#{i}") }
            }
            # generic domkey page_component but not a method in the view
            page_component = Component.new hash, watir_container
            CheckboxTextField.new(page_component)
          end
        end

      end

      # final client view that gets what the factory for page_components
      class DomainSpecificComponentView
        include CheckboxTextFieldViewFactory

      end

      it 'view factory' do
        view = DomainSpecificComponentView.new

        expect(view.features.size).to eq(2)
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