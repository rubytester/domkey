describe Domkey::View::OptionSelectable do

  class OptionSelectableFaker
    include Domkey::View::OptionSelectable
  end

  before :all do
    @o = OptionSelectableFaker.new
  end

  context 'set' do

    it 'set string' do
      expect(@o).to receive(:set_by_value)
      @o.set('fake')
    end

    it 'set by symbol' do
      expect(@o).to receive(:set_by_symbol)
      @o.set :hello_world
    end

    it 'set by not implemented strategy' do
      expect { @o.set Object.new }.to raise_error(Domkey::Exception::NotImplementedError)
    end

    it 'set regex' do
      expect(@o).to receive(:set_by_value)
      @o.set(/fake/)
    end

    it 'set :value' do
      expect(@o).to receive(:set_by_value)
      @o.set(:value => 'fake')
    end

    it 'set :label' do
      expect(@o).to receive(:set_by_label)
      @o.set(:label => 'fake')
    end

    it 'set :text' do
      expect(@o).to receive(:set_by_label)
      @o.set(:text => 'fake')
    end

    it 'set :index' do
      expect(@o).to receive(:set_by_index)
      @o.set(:index => 3)
    end

    it 'string' do
      expect { @o.set('fake') }.to raise_error(Domkey::Exception::NotImplementedError)
    end

    it 'regex' do
      expect { @o.set(/fake/) }.to raise_error(Domkey::Exception::NotImplementedError)
    end

    it ':label' do
      expect { @o.set(:label => 'fake') }.to raise_error(Domkey::Exception::NotImplementedError)
    end

    it ':text' do
      expect { @o.set(:text => 'fake') }.to raise_error(Domkey::Exception::NotImplementedError)
    end

    it ':index' do
      expect { @o.set(:index => 3) }.to raise_error(Domkey::Exception::NotImplementedError)
    end

    it ':value' do
      expect { @o.set(:value => 'fake') }.to raise_error(Domkey::Exception::NotImplementedError)
    end

    it ':symbol' do
      expect { @o.set :hello_world }.to raise_error(Domkey::Exception::NotImplementedError)
    end

  end

  context 'value' do

    it 'value default' do
      expect(@o).to receive(:value_by_default)
      @o.value
    end

    it 'value option' do
      expect(@o).to receive(:value_by_options)
      @o.value(:foo)
    end

    it 'default' do
      expect { @o.value }.to raise_error(Domkey::Exception::NotImplementedError)
    end

    it 'option' do
      expect { @o.value(:foo) }.to raise_error(Domkey::Exception::NotImplementedError)
    end


  end

  context 'options' do

    it 'options default' do
      expect(@o).to receive(:options_by_default)
      @o.options
    end

    it 'options opt' do
      expect(@o).to receive(:options_by)
      @o.options(:foo)
    end

    it 'default' do
      expect { @o.options }.to raise_error(Domkey::Exception::NotImplementedError)
    end

    it 'opts' do
      expect { @o.options(:foo) }.to raise_error(Domkey::Exception::NotImplementedError)
    end

  end
end