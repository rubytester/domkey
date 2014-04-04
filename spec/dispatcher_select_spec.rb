require 'spec_helper'

describe Domkey::View::Widgetry::Dispatcher do

  context Domkey::View::Widgetry::Select do

    context "Multi" do

      before :all do
        @object = Domkey.browser.select(id: 'multiselect')
        @widget = Domkey::View::Widgetry.dispatcher(@object)
      end

      before :each do
        goto_html("test.html")
      end

      it 'initial value on the test page' do
        @widget.value.should eql ["English", "Norwegian"]
      end

      it 'set array of strings clears all. sets text items provided. value is array of visible texts' do
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

      it 'set by text' do
        @widget.set text: 'Polish'
        @widget.value.should eql ["Polish"]
      end

      it 'set by array of texts' do
        # client would not usually do this.
        # Client would simply call set ['Polish', 'Norwegian']
        # becuase text: qualifer is a default way of setting select list by visible text
        @widget.set text: ['Polish', 'Norwegian']
        @widget.value.should eql ["Norwegian", "Polish"]
      end

      it 'set index by option position' do
        @widget.set index: 1
        @widget.value.should eql ['English']
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
        @widget.options.should eql [{:text=>"Danish", :value=>"1"},
                                    {:text=>"English", :value=>"2"},
                                    {:text=>"Norwegian", :value=>"3"},
                                    {:text=>"Polish", :value=>""},
                                    {:text=>"Swedish", :value=>"Swedish"}]
      end

    end

    context "Single" do

      before :all do
        object  = Domkey.browser.select(id: 'fruit_list')
        @widget = Domkey::View::Widgetry.dispatcher(object)
      end

      before :each do
        goto_html("test.html")
      end

      it 'initial value on the test page visible text to the user' do
        @widget.value.should eql ['Default']
      end

      it 'set string selects visible text. value is visible text to the user' do
        # option text
        @widget.set 'Tomato'
        @widget.value.should eql ['Tomato'] # not value attribute, visible text [text, label]

        # option label attribute text
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
        @widget.options.should eql [{:text=>"Tomato", :value=>"tomato"},
                                    {:text=>"Cucumber", :value=>"gurken"},
                                    {:text=>"Other", :value=>""},
                                    {:text=>"Default", :value=>"Default"}]
      end

    end

  end

end
