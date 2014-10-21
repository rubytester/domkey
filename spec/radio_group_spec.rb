require 'spec_helper'

describe Domkey::View::RadioGroup do

  class RadioGroupExampleView
    include Domkey::View

    # one named radio group
    def group
      RadioGroup.new -> { radios(name: 'tool') }
    end

    # no good. collection resolves to more than one coherent group
    def not_valid_group
      RadioGroup.new -> { radios(name: /^tool/) }
    end
  end

  before :each do
    goto_html("test.html")

    @v = RadioGroupExampleView.new
    @v.group.count.should == 3
    @v.group.to_a.each { |e| e.should be_kind_of(Domkey::View::PageObject) }
  end

  it 'should fail when group defintion finds 2 distinct groups' do
    v = RadioGroupExampleView.new
    expect { v.not_valid_group.to_a }.to raise_error(Domkey::Exception::Error, /definition scope too broad: Found 2 radio groups/)
  end

  it 'initial value on test page' do
    expect(@v.group.value).to eq ['other']
    # using option qualifieres
    expect(@v.group.value :index, :value, :label, :text).to eq [{:index => 2, :value => "other", :label => "Other", :text => "Other"}]
    expect(@v.group.value [:index]).to eq [{:index => 2}]
    expect(@v.group.value [:value]).to eql [{:value => 'other'}]
  end

  it 'options by default should return value attribute of each radio' do
    expect(@v.group.options).to eq ["cucumber", "tomato", "other"]
  end

  it 'set string matching value attribute' do
    @v.group.set 'tomato'
    expect(@v.group.value).to eq ['tomato']
  end

  it 'set regexp matching value attribute' do
    @v.group.set /^oth/
    expect(@v.group.value).to eq ['other']
  end

  it 'set array of value attribute. last value wins' do
    # since this is single select sending an array will in turn set each element and the last one wins
    # respect the interface of OptionSelectable set
    @v.group.set ['other', 'tomato', /cucu/]
    expect(@v.group.value).to eq ['cucumber']
  end

  it 'set false has no effect' do
    @v.group.set false
    expect(@v.group.value).to eq ['other']
  end

  it 'set true has no effect' do
    @v.group.set true
    expect(@v.group.value).to eq ['other']
  end

  it 'set by not implemented symbol errors' do
    expect { @v.group.set :hello_world }.to raise_error(Domkey::Exception::NotImplementedError, /Unknown way of setting by value/)
  end

  it 'set empty array has no effect' do
    @v.group.set []
    expect(@v.group.value).to eq ['other']
  end

  it 'set value string not found error' do
    expect { @v.group.set 'foobar' }.to raise_error(Domkey::Exception::NotFoundError, /not found with value/)
  end

  it 'set value regexp not found error' do
    expect { @v.group.set /balaba/ }.to raise_error(Domkey::Exception::NotFoundError, /not found with value/)
  end

  context "using OptionSelectable qualifiers" do

    it 'set by index single' do
      @v.group.set index: 1
      expect(@v.group.value).to eq ['tomato']
    end

    context "set by array should select each but the last one wins" do

      it 'set by index array the last one wins' do
        @v.group.set index: [0, 2, 1]
        expect(@v.group.value).to eq ['tomato']
      end

      it 'set by index array string, regex' do
        @v.group.set label: ['Cucumber', /mato/]
        expect(@v.group.value).to eq ['tomato']
      end

    end

    it 'set by label string' do
      @v.group.set label: 'Tomato'
      expect(@v.group.value).to eq ['tomato']
      expect(@v.group.value :text).to eq [{text: 'Tomato'}]
    end

    it 'set by label regexp' do
      @v.group.set label: /umber/
      expect(@v.group.value).to eq ['cucumber']
    end

    it 'options by opts single' do
      v = [{:value => "cucumber"}, {:value => "tomato"}, {:value => "other"}]
      expect(@v.group.options :value).to eq v
      expect(@v.group.options [:value]).to eq v
    end

    it 'options by label' do
      v = [{:label => "Cucumber"}, {:label => "Tomato"}, {:label => "Other"}]
      expect(@v.group.options :label).to eq v
      expect(@v.group.options [:label]).to eq v
    end

    it 'options by opts many' do
      v = [{:value => "cucumber", :index => 0, :label => "Cucumber", :text => "Cucumber"},
           {:value => "tomato", :index => 1, :label => "Tomato", :text => "Tomato"},
           {:value => "other", :index => 2, :label => "Other", :text => "Other"}]

      expect(@v.group.options :value, :index, :label, :text).to eq v
      expect(@v.group.options [:value, :index, :label, :text]).to eq v
    end
  end
end
