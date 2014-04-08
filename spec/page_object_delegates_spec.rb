require 'spec_helper'

# methods each pageobject should have
# set value options elements

describe Domkey::View::PageObject do

  before :all do
    goto_html("test.html")
  end

  context 'wrapping single watir elements' do

    context 'dispatcher bridges set value and options messages' do

      it 'select' do
        o = Domkey::View::PageObject.new -> { select_list(id: 'fruit_list') }
        o.set 'Tomato'
        o.value.should eql 'tomato'
      end

    end

    context 'delegate unimplmemented messages' do

      before :all do
        @o = Domkey::View::PageObject.new -> { text_field(id: 'city1') }
      end

      it 'should delegate to element when element responds' do
        @o.should respond_to(:id)
        @o.id.should eql 'city1'

        @o.should respond_to(:click)
        @o.click
      end

      it 'should not delegate to element when element does not repsond' do
        @o.should_not respond_to(:textaramabada)
        expect { @o.textaramabada }.to raise_error(NoMethodError)
      end
    end

  end
end
