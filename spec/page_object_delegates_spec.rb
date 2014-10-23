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
        expect(o.value).to eq 'tomato'
      end

    end

    context 'delegate unimplmemented messages' do

      before :all do
        @o = Domkey::View::PageObject.new -> { text_field(id: 'city1') }
      end

      it 'should delegate to element when element responds' do
        expect(@o).to respond_to(:id)
        expect(@o.id).to eq 'city1'

        expect(@o).to respond_to(:click)
        @o.click
      end

      it 'should not delegate to element when element does not repsond' do
        expect(@o).to_not respond_to(:textaramabada)
        expect { @o.textaramabada }.to raise_error(NoMethodError)
      end
    end

  end
end
