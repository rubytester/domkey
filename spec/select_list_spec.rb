require 'spec_helper'

describe Domkey::View::SelectList do

  class SelectListExampleView

    include Domkey::View

    select_list(:singlelist) { select_list(id: 'fruit_list') }

    select_list(:multilist) { select_list(id: 'multiselect') }
    # example of building SelectList as a method, factory respects watir_container
    # def multilist
    #   SelectList.new -> { select_list(id: 'multiselect') }, -> { watir_container }
    # end

  end

  context "Multi" do

    before :all do
      @view   = SelectListExampleView.new
      @widget = @view.multilist
    end

    before :each do
      goto_html("test.html")
      @widget.set false #unselect all first
    end

    it 'options by default' do
      expect(@widget.options).to eq ["1", "2", "3", "", "Swedish"]
    end

    it 'set value string' do
      @widget.set '1'
      expect(@widget.value).to eq ['1']
    end

    it 'set value array string' do
      @widget.set ['1', '3']
      expect(@widget.value).to eq ['1', '3']
    end

    it 'set false clears all. value is empty array' do
      @widget.set ['1', '3']
      @widget.set false
      expect(@widget.value).to eq []
    end

    it 'set empty array should not modify state' do
      @widget.set ['1', '3'] #seed
      @widget.set [] #append none
      expect(@widget.value).to eq ["1", "3"]
    end

    context "using OptionSelectable qualifiers" do

      it 'set by text' do
        @widget.set text: 'Polish'
        expect(@widget.value).to eq [""] #option has no value attribute defined
        expect(@widget.value :text).to eq :text => ["Polish"]
      end

      it 'set by array of texts' do
        @widget.set text: ['Polish', /orwegia/]
        expect(@widget.value).to eq ["3", ""]
        expect(@widget.value :text).to eq :text => ["Norwegian", "Polish"]
      end

      it 'set by position index' do
        @widget.set index: 1
        expect(@widget.value).to eq ['2']
        expect(@widget.value :index, :value).to eq index: [1], value: ['2']
      end

      it 'set index array of option positions' do
        @widget.set index: [0, 2]
        expect(@widget.value).to eq ["1", "3"]
        expect(@widget.value :index).to eq :index => [0, 2]
      end

      it 'set value attribute string' do
        @widget.set value: '2'
        expect(@widget.value).to eq ['2']
      end

      it 'set value attribute array of strings' do
        @widget.set value: ['2', '1']
        expect(@widget.value).to eq ["1", "2"]
      end

      it 'set by many qualifiers at once' do
        @widget.set value: ['2', '1'],
                    text:  'Swedish',
                    index: 3
        expect(@widget.value).to eq ["1", "2", "", "Swedish"]
        expect(@widget.value :text, :index).to eq :text => ["Danish", "English", "Polish", "Swedish"], :index => [0, 1, 3, 4]
      end

      it 'set appends in multiselect' do
        @widget.set value: ['2', '1'], index: 3
        expect(@widget.value).to eq ["1", "2", ""]
        # now append extra one
        @widget.set text: 'Swedish'
        expect(@widget.value).to eq ["1", "2", "", "Swedish"]
      end

      it 'options by qualifiers' do
        expected = [{:text => "Danish", :value => "1", :index => 0},
                    {:text => "English", :value => "2", :index => 1},
                    {:text => "Norwegian", :value => "3", :index => 2},
                    {:text => "Polish", :value => "", :index => 3},
                    {:text => "Swedish", :value => "Swedish", :index => 4}]

        expect(@widget.options :text, :value, :index).to eq expected

      end

      it 'set by unimplmemented qualifier' do
        expect { @widget.set :hello_world => 'hello world' }.to raise_error(Domkey::Exception::NotImplementedError, /Unknown option qualifier/)
      end

    end

    it 'set regexp acts on value' do
      @widget.set /2/
      expect(@widget.value).to eq ["2"]
    end

    it 'set by symbol' do
      expect { @widget.set :hello_world }.to raise_error(Domkey::Exception::NotImplementedError, /Unknown way of setting by value/)
    end

    context "using view payload" do

      it 'value attributes as default' do
        payload = {:multilist => ['1', '3']}
        @view.set payload
        expect(@widget.value).to eq ['1', '3']
        expect(@view.value payload).to eq :multilist => ["1", "3"]
      end

      it 'text qualifier' do
        payload = {:multilist => {:text => ["Norwegian", "Swedish"]}}
        @view.set payload
        expect(@widget.value :text).to eq payload[:multilist]
        expect(@view.value payload).to eq payload
      end

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

    it 'default initial value attributes' do
      expect(@widget.value).to eq ['Default']
    end

    it 'default options returns value attributes' do
      expect(@widget.options).to eq ['tomato', 'gurken', '', 'Default']
    end

    it 'set string selects value attribute' do
      @widget.set 'tomato'
      expect(@widget.value).to eq ['tomato']

      # select new unselects previous behaivor of select list single
      @widget.set 'gurken'
      expect(@widget.value).to eq ['gurken']
    end

    it 'set when value not present should error' do
      expect { @widget.set '' }.to raise_error(Watir::Exception::NoValueFoundException)
      expect(@widget.value).to eq ['Default'] #interesting quirk
    end

    it 'set array of text selects one by one and last one wins' do
      @widget.set ['gurken', 'tomato'] #cycle on single select list
      expect(@widget.value).to eq ['tomato'] # the last one set
    end

    it 'set false has no effect' do
      @widget.set false
      expect(@widget.value).to eq ['Default']
    end

    it 'set empty array has no effect' do
      @widget.set []
      expect(@widget.value).to eq ['Default']
    end

    context "using OptionSelectable qualifiers" do

      it 'set by array of text' do
        @widget.set text: ['Other', 'Tomato']
        expect(@widget.value).to eq ['tomato']
        expect(@widget.value :text).to eq text: ['Tomato']
      end

      it 'default value qualified' do
        expect(@widget.value [:index, :value, :text]).to eq :index => [3], :value => ["Default"], :text => ["Default"]
      end

      it 'set index position' do
        @widget.set index: 1
        expect(@widget.value).to eq ['gurken']
        expect(@widget.value :index).to eq index: [1]
      end

      it 'set index array' do
        @widget.set index: [2, 1]
        expect(@widget.value).to eq ['gurken'] # the last one wins
        expect(@widget.value :index, :value).to eq :index => [1], :value => ["gurken"]
      end

      it 'set value attribute string' do
        #equivalenet to set 'tomato' becuse :value attribute is default way of selecting
        @widget.set value: 'tomato'
        expect(@widget.value :value).to eq value: ['tomato']
      end

      it 'set value attribute array of strings' do
        @widget.set value: ['tomato', 'gurken']
        expect(@widget.value :value).to eq value: ['gurken'] #last wins
      end

      it 'example set by many qualifiers at once' do
        @widget.set value: ['gurken'],
                    text:  'Tomato',
                    index: 1
        expect(@widget.value :value, :text, :index).to eq :value => ["gurken"], :text => ["Cucumber"], :index => [1] #last one wins
      end


      it 'options qualified' do
        v = [{:text => "Tomato", :value => "tomato", :index => 0},
             {:text => "Cucumber", :value => "gurken", :index => 1},
             {:text => "Other", :value => "", :index => 2},
             {:text => "Default", :value => "Default", :index => 3}]
        expect(@widget.options :text, :value, :index).to eq v
      end


    end
  end
end
