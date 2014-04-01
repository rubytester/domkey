require 'spec_helper'

describe Domkey::View::LabeledGroup do

  class LabeledGroupExampleView
    include Domkey::View

    def radio_group
      RadioGroup.new -> { radios(name: 'tool') }
    end

    #labelled radio_group with tool: as semantic descriptor
    def tool
      LabeledGroup.new(radio_group)
    end

    def checkbox_group
      CheckboxGroup.new -> { checkboxes(name: 'fruit') }
    end

    #labelled checkbox_group with fruit: as semantic descriptor
    def fruit
      LabeledGroup.new(checkbox_group)
    end
  end

  let(:view) { LabeledGroupExampleView.new }

  before :all do
    goto_html("test.html")
  end

  context 'radio group' do

    context 'wrapped directly' do

      it 'set string' do
        view.tool.set 'Tomato'
        view.tool.value.should eql ['Tomato']
      end

      it 'set array' do
        view.tool.set ['Tomato', 'Cucumber']
        view.tool.value.should eql ['Cucumber']
      end

      it 'options' do
        view.tool.options.should eql ["Cucumber", "Tomato", "Other"]
      end

    end

    context 'to_labeled' do

      it 'set string' do
        view.tool.to_labeled.set 'Tomato'
        view.tool.to_labeled.value.should eql ['Tomato']
      end

      it 'set array' do
        view.tool.to_labeled.set ['Tomato', 'Cucumber']
        view.tool.to_labeled.value.should eql ['Cucumber']
      end

    end
  end

  context 'checkbox group' do

    context 'wrapped directly' do

      it 'set single' do
        view.fruit.set 'Tomatorama'
        view.fruit.value.should eql ['Tomatorama']
      end

      it 'set array' do
        view.fruit.set ['Tomatorama', 'Cucumberama']
        view.fruit.value.should eql ['Cucumberama', 'Tomatorama']
      end

      it 'options' do
        view.fruit.options.should eql ["Cucumberama", "Tomatorama", "Other"]
      end
    end

    context 'to_labeled' do

      it 'set single' do
        view.fruit.to_labeled.set 'Tomatorama'
        view.fruit.to_labeled.value.should eql ['Tomatorama']
      end

      it 'set array' do
        view.fruit.to_labeled.set ['Tomatorama', 'Cucumberama']
        view.fruit.to_labeled.value.should eql ['Cucumberama', 'Tomatorama']
      end
    end
  end
end