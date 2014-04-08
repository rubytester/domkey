require 'spec_helper'

describe Domkey::View::OptionSelectable do

  class OptionSelectableFaker
    include Domkey::View::OptionSelectable
  end

  before :all do
    @widget = OptionSelectableFaker.new
  end

  context 'set' do

    it 'set string' do
      expect(@widget).to receive(:set_by_value)
      @widget.set('fake')
    end

    it 'set by symbol' do
      expect(@widget).to receive(:set_by_symbol)
      @widget.set :hello_world
    end

    it 'set by not implemented strategy' do
      expect { @widget.set Object.new }.to raise_error(Domkey::Exception::NotImplementedError)
    end

    it 'set regex' do
      expect(@widget).to receive(:set_by_value)
      @widget.set(/fake/)
    end

    it 'set :value' do
      expect(@widget).to receive(:set_by_value)
      @widget.set(:value => 'fake')
    end

    it 'set :label' do
      expect(@widget).to receive(:set_by_label)
      @widget.set(:label => 'fake')
    end

    it 'set :text' do
      expect(@widget).to receive(:set_by_label)
      @widget.set(:text => 'fake')
    end

    it 'set :index' do
      expect(@widget).to receive(:set_by_index)
      @widget.set(:index => 3)
    end

    it 'string' do
      expect { @widget.set('fake') }.to raise_error(Domkey::Exception::NotImplementedError)
    end

    it 'regex' do
      expect { @widget.set(/fake/) }.to raise_error(Domkey::Exception::NotImplementedError)
    end

    it ':label' do
      expect { @widget.set(:label => 'fake') }.to raise_error(Domkey::Exception::NotImplementedError)
    end

    it ':text' do
      expect { @widget.set(:text => 'fake') }.to raise_error(Domkey::Exception::NotImplementedError)
    end

    it ':index' do
      expect { @widget.set(:index => 3) }.to raise_error(Domkey::Exception::NotImplementedError)
    end

    it ':value' do
      expect { @widget.set(:value => 'fake') }.to raise_error(Domkey::Exception::NotImplementedError)
    end

    it ':symbol' do
      expect { @widget.set :hello_world }.to raise_error(Domkey::Exception::NotImplementedError)
    end

  end

  context 'value' do

    it 'value default' do
      expect(@widget).to receive(:value_by_default)
      @widget.value
    end

    it 'value option' do
      expect(@widget).to receive(:value_by_options)
      @widget.value(:foo)
    end

    it 'default' do
      expect { @widget.value }.to raise_error(Domkey::Exception::NotImplementedError)
    end

    it 'option' do
      expect { @widget.value(:foo) }.to raise_error(Domkey::Exception::NotImplementedError)
    end


  end

  context 'options' do

    it 'options default' do
      expect(@widget).to receive(:options_by_default)
      @widget.options
    end

    it 'options opt' do
      expect(@widget).to receive(:options_by)
      @widget.options(:foo)
    end

    it 'default' do
      expect { @widget.options }.to raise_error(Domkey::Exception::NotImplementedError)
    end

    it 'opts' do
      expect { @widget.options(:foo) }.to raise_error(Domkey::Exception::NotImplementedError)
    end

  end
end