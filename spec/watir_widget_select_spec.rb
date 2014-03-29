require 'spec_helper'

describe Domkey::View::WatirWidget do

  context Watir::Select do

    context "Multi" do

      before :all do
        @object = Domkey.browser.select(id: 'multiselect')
        @widget = Domkey::View::WatirWidget.new(@object)
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

      it 'set string clears all. sets one text item. value is one item' do
        @widget.set 'Polish'
        @widget.value.should eql "Polish" # or should we return ['Polish'] in this case?
      end

    end

    context "Single" do

      before :all do
        object  = Domkey.browser.select(id: 'fruit_list')
        @widget = Domkey::View::WatirWidget.new(object)
      end

      before :each do
        goto_html("test.html")
      end

      it 'initial value on the test page visible text to the user' do
        @widget.value.should eql 'Tomato'
      end

      it 'set string selects visible text. value is visible text to the user' do
        # option text
        @widget.set 'Tomato'
        @widget.value.should eql 'Tomato' # not value attribute, visible text [text, label]

        # option label attribute text
        @widget.set 'Other'
        @widget.value.should eql 'Other'
      end

      it 'set array of text or label' do
        @widget.set ['Other', 'Tomato'] #cycle on single select list
        @widget.value.should eql 'Tomato' # the last one set
      end

      it 'set false has no effect on single select list' do
        @widget.set false
        @widget.value.should eql 'Tomato'
      end

      it 'set index position' do
        @widget.set index: 1
        @widget.value.should eql 'Cucumber'
      end

    end

  end

end
