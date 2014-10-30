require 'spec_helper'

describe Domkey::View::LabeledGroup do

  class LabeledGroupExampleView
    include Domkey::View

    radio_group(:radio_group) { radios(name: 'tool') }

    #labeled radio_group with tool: as semantic descriptor
    def tool
      LabeledGroup.new(radio_group)
    end

    checkbox_group(:checkbox_group) { checkboxes(name: 'fruit') }

    #labeled checkbox_group with fruit: as semantic descriptor
    def fruit
      LabeledGroup.new(checkbox_group)
    end
  end

  let(:view) { LabeledGroupExampleView.new }

  before :all do
    goto_html("test.html")
  end

  context 'radio group' do

    context 'wrapped as LabeledGroup' do

      it 'set string' do
        view.tool.set 'Tomato'
        expect(view.tool.value).to eq ['Tomato']
        # using view payload
        payload = {tool: ["Cucumber"]}
        view.set payload
        expect(view.value :tool).to eq payload
      end

      it 'set regex' do
        view.tool.set /umber$/
        expect(view.tool.value).to eq ['Cucumber']
      end

      it 'set array' do
        view.tool.set ['Tomato', 'Cucumber']
        expect(view.tool.value).to eq ['Cucumber']
      end

      it 'set array string and regex' do
        view.tool.set ['Tomato', /cumber$/]
        expect(view.tool.value).to eq ['Cucumber']
      end

      it 'set value text not found should error' do
        expect { view.tool.set 'yepyep' }.to raise_error(Domkey::Exception::Error, /Label text to set not found/)
      end

      it 'set value regexp not found should error' do
        expect { view.tool.set /fofofo/ }.to raise_error(Domkey::Exception::Error, /Label text to set not found/)
      end

      it 'options' do
        expect(view.tool.options).to eq ["Cucumber", "Tomato", "Other"]
      end

    end

    context 'to_labeled' do

      it 'set string' do
        view.radio_group.to_labeled.set 'Tomato'
        expect(view.radio_group.to_labeled.value).to eq ['Tomato']
      end

      it 'set array' do
        view.radio_group.to_labeled.set ['Tomato', 'Cucumber']
        expect(view.radio_group.to_labeled.value).to eq ['Cucumber']
      end

    end
  end

  context 'checkbox group' do

    context 'wrapped as LabeledGroup' do

      it 'set single' do
        view.fruit.set 'Tomatorama'
        expect(view.fruit.value).to eq ['Tomatorama']
      end

      it 'set array' do
        view.fruit.set ['Tomatorama', 'Cucumberama']
        expect(view.fruit.value).to eq ['Cucumberama', 'Tomatorama']
      end

      it 'set using view payload' do
        payload = {fruit: ['Tomatorama', 'Other']}
        view.set payload
        expect(view.value :fruit).to eq payload
      end

      it 'options' do
        expect(view.fruit.options).to eq ["Cucumberama", "Tomatorama", "Other"]
      end
    end

    context 'to_labeled' do

      it 'set single' do
        view.checkbox_group.to_labeled.set 'Tomatorama'
        expect(view.checkbox_group.to_labeled.value).to eq ['Tomatorama']
      end

      it 'set array' do
        view.checkbox_group.to_labeled.set ['Tomatorama', 'Cucumberama']
        expect(view.checkbox_group.to_labeled.value).to eq ['Cucumberama', 'Tomatorama']
      end
    end
  end
end