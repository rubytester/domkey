require 'spec_helper'

describe Domkey::View do

  class SingleDom
    include Domkey::View
    dom(:street) { text_field(class: 'street1') }

    # or you can use factory method:
    # select_list(:multilist) { select_list(id: 'multiselect') }
    def multilist
      SelectList.new -> { select_list(id: 'multiselect') }, watir_container
    end

    checkbox_group(:cbg) { checkboxes(name: 'fruit') }

    def nested_view
      SingleDomNestedView.new browser.div(id: 'container')
    end
  end

  class SingleDomNestedView
    include Domkey::View
    # street exists in parent view and also in this nested view
    dom(:street) { text_field(class: 'street1') }
  end

  before :all do
    goto_html("test.html")
  end

  context 'dom for single element' do

    before :each do
      @view = SingleDom.new
    end

    it 'view responds to dom' do
      expect(@view).to respond_to(:street)
    end

    it 'dom returns Component' do
      expect(@view.street).to be_a(Domkey::View::Component)
    end

    context 'payload should driver set value and options' do

      it "text_field" do
        payload = {:street => 'Aha'}
        @view.set payload
        expect(@view.value payload).to eq payload
        expect(@view.options payload).to eq :street => [] #not opiton selectable page component
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

  context 'view method returns view that acts like page_component' do
    before :all do
      @view = SingleDom.new
    end

    it 'view semantic descriptor returns view' do
      expect(@view.nested_view).to be_a(Domkey::View)
    end

    it 'view within view is a page component' do
      expect(@view.nested_view.street).to be_a(Domkey::View::Component)
    end

    it 'page_component in nested view adopts container from parent view' do
      expect(@view.nested_view.watir_container).to be_a(Watir::Div)
      expect(@view.nested_view.street.watir_container).to be_a(Watir::Div)
    end


    it 'value requires args' do
      expect { @view.nested_view.value }.to raise_error
    end

    it 'setting and value args' do
      @view.nested_view.set street: 'Nowy Świat'
      expect(@view.nested_view.value :street).to eq :street => "Nowy Świat"
      expect(@view.nested_view.value [:street]).to eq :street => "Nowy Świat"
    end
  end

  context 'register_domkey_factory' do

    # develop custom page component in this container
    module RegisterDomkeyExample

      class MyComponent < Domkey::View::Component

      end
      # and register it with View so you can have factory shortcut constructor
      Domkey::View.register_domkey_factory :page_component_with_hash, RegisterDomkeyExample::MyComponent
    end

    class RegisterDomkeyFactoryView
      include Domkey::View

      # then this factory method should be available in View
      page_component_with_hash :po_with_hash_example, key: -> { "fake key value" }
    end

    it 'class method exists for view' do
      expect(RegisterDomkeyFactoryView).to respond_to(:page_component_with_hash)
    end

    it 'view constructed method for the object after being instantiated' do
      view = RegisterDomkeyFactoryView.new
      expect(view).to respond_to(:po_with_hash_example)
      expect(view.po_with_hash_example).to be_a(RegisterDomkeyExample::MyComponent)
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
