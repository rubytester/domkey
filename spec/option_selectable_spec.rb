require 'spec_helper'

describe Domkey::View::OptionSelectable do

  class OptionSelectableFaker
    include Domkey::View::OptionSelectable
  end

  before :all do
    @widget = OptionSelectableFaker.new
  end

  it 'set string' do
    expect { @widget.set('fake') }.to raise_error(Domkey::Exception::NotImplementedError)
  end

  it 'set regex' do
    expect { @widget.set(/fake/) }.to raise_error(Domkey::Exception::NotImplementedError)
  end

  it 'set :label' do
    expect { @widget.set(:label => 'fake') }.to raise_error(Domkey::Exception::NotImplementedError)
  end

  it 'set :text' do
    expect { @widget.set(:text => 'fake') }.to raise_error(Domkey::Exception::NotImplementedError)
  end

  it 'set :index' do
    expect { @widget.set(:index => 3) }.to raise_error(Domkey::Exception::NotImplementedError)
  end

  it 'set :value' do
    expect { @widget.set(:value => 'fake') }.to raise_error(Domkey::Exception::NotImplementedError)
  end

  it 'value default' do
    expect { @widget.value }.to raise_error(Domkey::Exception::NotImplementedError)
  end

  it 'value option' do
    expect { @widget.value(:foo) }.to raise_error(Domkey::Exception::NotImplementedError)
  end

  it 'options default' do
    expect { @widget.options }.to raise_error(Domkey::Exception::NotImplementedError)
  end

  it 'options opt' do
    expect { @widget.options(:foo) }.to raise_error(Domkey::Exception::NotImplementedError)
  end

end




