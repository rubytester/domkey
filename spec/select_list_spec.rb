require 'spec_helper'

describe Domkey::View::SelectList do

  class SelectListExampleView

    include Domkey::View

    def multilist
      SelectList.new -> { select_list(id: 'multiselect') }
    end

    def singlelist
      SelectList.new -> { select_list(id: 'fruit_list') }
    end

  end

  context "Multi" do

    before :all do
      view    = SelectListExampleView.new
      @widget = view.multilist
    end

    before :each do
      goto_html("test.html")
      @widget.set false
    end

    it 'initial example' do
      @widget.set ["2", "3"]
      @widget.value.should eql ["2", "3"]
      # array
      @widget.value([:index, :text, :value]).should eql [{:index => 1, :text => "English", :value => "2"}, {:index => 2, :text => "Norwegian", :value => "3"}]
      # splat list
      @widget.value(:index, :label).should eql [{:index => 1, :label => "English"}, {:index => 2, :label => "Norwegian"}]

      # one element array
      @widget.value([:index]).should eql [{:index => 1}, {:index => 2}]
      # one elmenet splat list
      @widget.value(:value).should eql [{:value => "2"}, {:value => "3"}]

    end

    it 'set value string' do
      @widget.set '1'
      @widget.value.should eql ['1']
    end

    it 'set value array string' do
      @widget.set ['1', '3']
      @widget.value.should eql ['1', '3']
    end

    it 'set false clears all. value is empty array' do
      @widget.set false
      @widget.value.should eql []
    end

    it 'set empty array clears all. value is empty array' do
      @widget.set []
      @widget.value.should eql []
    end

    it 'set string' do
      @widget.set text: 'Polish'
      @widget.value.should eql [""] #option has no value attribute defined
    end

    it 'set regexp' do
      @widget.set /2/
      @widget.value.should eql ["2"]
    end

    it 'set by array of texts' do
      @widget.set text: ['Polish', /orwegia/]
      @widget.value.should eql ["3", ""]
    end

    it 'set index by option position' do
      @widget.set index: 1
      @widget.value.should eql ['2']
      @widget.value(:index, :value).should eql [{index: 1, value: '2'}]
    end

    it 'set index array of option positions' do
      @widget.set index: [0, 2]
      @widget.value.should eql ["1", "3"]
    end

    it 'set value attribute string' do
      @widget.set value: '2'
      @widget.value.should eql ['2']
    end

    it 'set value attribute array of strings' do
      @widget.set value: ['2', '1']
      @widget.value.should eql ["1", "2"]
    end

    it 'set by many qualifiers at once' do
      @widget.set value: ['2', '1'],
                  text:  'Swedish',
                  index: 3
      @widget.value.should eql ["1", "2", "", "Swedish"]
    end

    it 'set appends in multiselect' do
      @widget.set value: ['2', '1'], index: 3
      @widget.value.should eql ["1", "2", ""]
      @widget.set text: 'Swedish'
      @widget.value.should eql ["1", "2", "", "Swedish"]
    end


    it 'set by symbol' do
      expect { @widget.set :hello_world }.to raise_error(Domkey::Exception::NotImplementedError)
    end

    it 'options by default' do
      @widget.options.should eql ["1", "2", "3", "", "Swedish"]
    end

    it 'options by opts' do

      expected = [{:text => "Danish", :value => "1", :index => 0},
                  {:text => "English", :value => "2", :index => 1},
                  {:text => "Norwegian", :value => "3", :index => 2},
                  {:text => "Polish", :value => "", :index => 3},
                  {:text => "Swedish", :value => "Swedish", :index => 4}]

      @widget.options(:text, :value, :index).should eql expected

    end
  end

  context "Single" do

    before :all do
      view    = SelectListExampleView.new
      @widget = view.singlelist
    end

    before :each do
      goto_html("test.html")
    end

    it 'initial value' do
      @widget.value.should eql ['Default']
    end

    it 'value keys' do
      @widget.value([:index, :value, :text]).should eql [{index: 3, value: 'Default', text: 'Default'}]
    end

    it 'set string selects value' do
      @widget.set 'tomato'
      @widget.value.should eql ['tomato']

      @widget.set 'gurken'
      @widget.value.should eql ['gurken']
    end

    it 'set when value not present should error' do
      expect { @widget.set '' }.to raise_error(Watir::Exception::NoValueFoundException)
      @widget.value.should eql ['Default'] #interesting quirk
    end

    it 'set array of text' do
      @widget.set ['gurken', 'tomato'] #cycle on single select list
      @widget.value.should eql ['tomato'] # the last one set
    end

    it 'set by array of text' do
      @widget.set text: ['Other', 'Tomato']
      @widget.value.should eql ['tomato']
    end

    it 'set false has no effect. value is selected item text' do
      @widget.set false
      @widget.value.should eql ['Default']
    end

    it 'set empty array has no effect. value is selected item text' do
      @widget.set []
      @widget.value.should eql ['Default']
    end

    it 'set index position' do
      @widget.set index: 1
      @widget.value.should eql ['gurken']
    end

    it 'set index array' do
      @widget.set index: [2, 1]
      @widget.value.should eql ['gurken'] # the last one wins
    end

    it 'set value attribute string' do
      @widget.set value: 'tomato'
      @widget.value.should eql ['tomato']
    end

    it 'set value attribute array of strings' do
      @widget.set value: ['tomato', 'gurken']
      @widget.value.should eql ['gurken']
    end

    it 'set by many qualifiers at once' do
      @widget.set value: ['gurken'],
                  text:  'Tomato',
                  index: 2
      @widget.value.should eql ['']
    end

    it 'options default' do

      @widget.options.should eql ['tomato', 'gurken', '', 'Default']

    end

    it 'options by specifiers' do
      expected = [{:text => "Tomato", :value => "tomato", :index => 0},
                  {:text => "Cucumber", :value => "gurken", :index => 1},
                  {:text => "Other", :value => "", :index => 2},
                  {:text => "Default", :value => "Default", :index => 3}]

      @widget.options(:text, :value, :index).should eql expected
    end
  end
end
