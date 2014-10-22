require 'spec_helper'

describe Domkey::View do

  class SingleDom
    include Domkey::View
    dom(:street) { text_field(class: 'street1') }

    def multilist
      SelectList.new -> { select_list(id: 'multiselect') }
    end

    def cbg
      CheckboxGroup.new -> { checkboxes(name: 'fruit') }
    end

    def container
      SingleDomContainer.new browser.div(id: 'container')
    end
  end

  class SingleDomContainer
    include Domkey::View
    dom(:street) { text_field(class: 'street1') }
  end

  before :all do
    goto_html("test.html")
  end

  context 'dom for single element' do

    before :all do
      @view = SingleDom.new
    end

    it 'view responds to dom' do
      expect(@view).to respond_to(:street)
    end

    it 'dom returns PageObject' do
      expect(@view.street).to be_a(Domkey::View::PageObject)
    end

    context 'payload should driver set value and options' do

      it "text_field" do
        payload = {:street => 'Aha'}
        @view.set payload
        expect(@view.value payload).to eq payload
        expect(@view.options payload).to eq :street => [] #not opiton selectable page object
      end

      context "option selectable" do

        it 'select_list' do
          payload = {:multilist => {:text => 'Polish'}}
          @view.set payload
          expect(@view.value payload).to eq :multilist => {:text => ["English", "Norwegian", "Polish"]}
          expect(@view.options payload).to eq :multilist => [{:text => "Danish"},
                                                             {:text => "English"},
                                                             {:text => "Norwegian"},
                                                             {:text => "Polish"},
                                                             {:text => "Swedish"}]
        end

        it 'checkbox group' do
          # has 2 qualifiers
          payload = {:cbg => {:label => 'Tomatorama', :index => 1}}
          @view.set(payload)
          expect(@view.value payload).to eq :cbg => {:label => ["Tomatorama", "Other"], :index => [1, 2]}
          expect(@view.options payload).to eq :cbg => [{:label => "Cucumberama", :index => 0}, {:label => "Tomatorama", :index => 1}, {:label => "Other", :index => 2}]
        end

      end
    end
  end

  context 'view method returns view that acts like pageobject' do
    before :all do
      @view = SingleDom.new
    end

    it 'view semantic descriptor returns view' do
      expect(@view.container).to be_a(Domkey::View)
    end

    it 'view within view is a page object' do
      expect(@view.container.street).to be_a(Domkey::View::PageObject)
    end

    it 'value requires args' do
      expect { @view.container.value }.to raise_error
    end

    it 'setting and value args' do
      @view.container.set street: 'Nowy Świat'
      expect(@view.container.value :street).to eq :street => "Nowy Świat"
      expect(@view.container.value [:street]).to eq :street => "Nowy Świat"
    end
  end
end

#require 'benchmark'
#Benchmark.bm do |bm|
#  howmany = 50
#  # setup browser
#  goto_html("test.html")
#  view = DomkeyExample::SingleDom.new Domkey.browser
#  bm.report('domkey') do
#    howmany.times do
#      view.street.set 'value'
#      view.street.value
#    end
#  end
#  bm.report('watir-') do
#    howmany.times do
#      Domkey.browser.text_field(class: 'street1').set 'value'
#      Domkey.browser.text_field(class: 'street1').value
#    end
#  end
#end
