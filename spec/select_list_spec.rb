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
    end

    it 'initial value on the test page' do
      @widget.value.should eql ["English", "Norwegian"]
    end

    it 'initial value by keys on the test page' do
      # array
      @widget.value([:index, :text, :value]).should eql [{:index=>1, :text=>"English", :value=>"2"}, {:index=>2, :text=>"Norwegian", :value=>"3"}]
      # splat list
      @widget.value(:index, :text).should eql [{:index=>1, :text=>"English"}, {:index=>2, :text=>"Norwegian"}]

      # one element array
      @widget.value([:index]).should eql [{:index=>1}, {:index=>2}]
      # one elmenet splat list
      @widget.value(:value).should eql [{:value=>"2"}, {:value=>"3"}]

    end

    it 'set string' do
      @widget.set 'Polish'
    end

    it 'set array string or regexp' do
      # texts are items visible to the user [text or label of select list option]
      @widget.set ['Polish', 'Norwegian']
      @widget.value.should eql ["Norwegian", "Polish"]
    end

    it 'set false clears all. value is empty array' do
      @widget.set false
      @widget.value.should eql []
    end

    it 'set empty array clears all. value is empty array' do
      @widget.set []
      @widget.value.should eql []
    end

    it 'set string clears all. sets one text item. value is one item' do
      @widget.set 'Polish'
      @widget.value.should eql ["Polish"]
    end

    it 'set string' do
      @widget.set text: 'Polish'
      @widget.value.should eql ["Polish"]
    end

    it 'set regexp' do
      @widget.set text: /olish/
      @widget.value.should eql ["Polish"]
    end

    it 'set by array of texts' do
      @widget.set text: ['Polish', /orwegia/]
      @widget.value.should eql ["Norwegian", "Polish"]
    end

    it 'set index by option position' do
      @widget.set index: 1
      @widget.value.should eql ['English']
      @widget.value(:index, :value).should eql [{index: 1, value: '2'}]
    end

    it 'set index array of option positions' do
      @widget.set index: [0, 2]
      @widget.value.should eql ["Danish", "Norwegian"]
    end

    it 'set value attribute string' do
      @widget.set value: '2'
      @widget.value.should eql ['English']
    end

    it 'set value attribute array of strings' do
      @widget.set value: ['2', '1']
      @widget.value.should eql ["Danish", "English"]
    end

    it 'set by many qualifiers at once' do
      @widget.set value: ['2', '1'],
                  text:  'Swedish',
                  index: 3
      @widget.value.should eql ['Danish', 'English', 'Polish', 'Swedish']
    end

    it 'options' do
      @widget.options.should eql [{:text=>"Danish", :value=>"1", :index=>0},
                                  {:text=>"English", :value=>"2", :index=>1},
                                  {:text=>"Norwegian", :value=>"3", :index=>2},
                                  {:text=>"Polish", :value=>"", :index=>3},
                                  {:text=>"Swedish", :value=>"Swedish", :index=>4}]
    end

    context "Single" do

      before :all do
        view    = SelectListExampleView.new
        @widget = view.singlelist
      end

      before :each do
        goto_html("test.html")
      end

      it 'initial value is text visible to the user' do
        @widget.value.should eql ['Default']
      end

      it 'value keys' do
        @widget.value([:index, :value, :text]).should eql [{index: 3, value: 'Default', text: 'Default'}]
      end

      it 'set string selects visible text. value is visible text to the user' do
        @widget.set 'Tomato'
        @widget.value.should eql ['Tomato']

        @widget.set 'Other'
        @widget.value.should eql ['Other']
      end

      it 'set array of text or label' do
        @widget.set ['Other', 'Tomato'] #cycle on single select list
        @widget.value.should eql ['Tomato'] # the last one set
      end

      it 'set by array of text' do
        @widget.set text: ['Other', 'Tomato']
        @widget.value.should eql ['Tomato']
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
        @widget.value.should eql ['Cucumber']
      end

      it 'set index array' do
        @widget.set index: [0, 2]
        @widget.value.should eql ['Other'] # the last one wins
      end

      it 'set value attribute string' do
        @widget.set value: 'tomato'
        @widget.value.should eql ['Tomato']
      end

      it 'set value attribute array of strings' do
        @widget.set value: ['tomato', 'gurken']
        @widget.value.should eql ['Cucumber']
      end

      it 'set by many qualifiers at once' do
        @widget.set value: ['gurken'],
                    text:  'Tomato',
                    index: 2
        @widget.value.should eql ['Other']
      end

      it 'options' do

        expected = [{:text=>"Tomato", :value=>"tomato", :index=>0},
                    {:text=>"Cucumber", :value=>"gurken", :index=>1},
                    {:text=>"Other", :value=>"", :index=>2},
                    {:text=>"Default", :value=>"Default", :index=>3}]

        @widget.options.should eql(expected)

      end

    end

  end

end