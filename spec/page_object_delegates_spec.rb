require 'spec_helper'

# methods each pageobject should have
# set value options elements

describe Domkey::View::PageObject do

  before :all do
    goto_html("test.html")
  end

  context 'delegate to element for missing methods' do
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