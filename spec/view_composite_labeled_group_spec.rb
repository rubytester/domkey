require 'spec_helper'
require 'domkey/view/composite/labeled_group'

describe Domkey::View::Composite::LabeledGroup do

  class PageObjectView
    include Domkey::View

    # one named radio group
    def tool
      rg = RadioGroup.new -> { radios(name: 'tool') }
      Domkey::View::Composite::LabeledGroup.new rg
    end

    def fruit
      cg = CheckboxGroup.new -> { checkboxes(name: 'fruit') }
      Domkey::View::Composite::LabeledGroup.new cg
    end

  end

  let(:view) { PageObjectView.new }

  before :all do
    goto_html("test.html")
  end

  context 'radio group' do

    it 'set string' do
      view.tool.set 'Tomato'
      view.tool.value.should eql ['Tomato']
    end

    it 'set array' do
      view.tool.set ['Tomato', 'Cucumber']
      view.tool.value.should eql ['Cucumber']
    end
  end

  context 'checkbox group' do

    it 'set single' do
      view.fruit.set 'Tomatorama'
      view.fruit.value.should eql ['Tomatorama']
    end

    it 'set array' do
      view.fruit.set ['Tomatorama', 'Cucumberama']
      view.fruit.value.should eql ['Cucumberama', 'Tomatorama']
    end
  end


end