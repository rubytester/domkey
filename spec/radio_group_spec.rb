require 'spec_helper'

describe Domkey::View::RadioGroup do

  class CollectionAsPageObjectRadioGroupView
    include Domkey::View

    # one named radio group
    def group
      RadioGroup.new -> { radios(name: 'tool') }
    end

    # no good. collection resolves to more than one coherent group
    def groups
      RadioGroup.new -> { radios(name: /^group/) }
    end
  end

  before :all do
    goto_html("test.html")
  end

  it 'two groups example' do
    v = CollectionAsPageObjectRadioGroupView.new
    expect { v.groups.to_a.size }.to raise_error
    expect { v.groups.map { |e| e } }.to raise_error
    expect { v.groups.count }.to raise_error
  end

  context "OptionSelectable object single" do
    # OptionSelectable object is an object that responds to options and is selectable by its optioins;
    # RadioGroup, Select, CheckboxGroup. CheckboxGroup acts like Multi Select, RadioGroup acts like Single Select

    before :each do
      goto_html("test.html")

      @v = CollectionAsPageObjectRadioGroupView.new
      @v.group.count.should == 3
      @v.group.to_a.each { |e| e.should be_kind_of(Domkey::View::PageObject) }
    end

    it 'initial value on test page' do
      @v.group.value.should eql ['other']
    end

    it 'set string' do
      @v.group.set 'tomato'
      @v.group.value.should eql ['tomato']
    end

    it 'set regexp' do
      @v.group.set /^oth/
      @v.group.value.should eql ['other']
    end

    it 'set array of value attribute. last value wins' do
      @v.group.set ['tomato']
      @v.group.value.should eql ['tomato']

      @v.group.set ['other', 'tomato', /cucu/]
      @v.group.value.should eql ['cucumber']
    end

    it 'set false has no effect' do
      @v.group.set false
      @v.group.value.should eql ['other']
    end

    it 'set empty array has no effect' do
      @v.group.set []
      @v.group.value.should eql ['other']
    end

    it 'set value string not found error' do
      expect { @v.group.set 'foobar' }.to raise_error
    end

    it 'set value regexp not found error' do
      expect { @v.group.set /balaba/ }.to raise_error
    end


    it 'set by index single' do
      @v.group.set index: 1
      @v.group.value.should eql ['tomato']
    end

    it 'set by index array' do
      @v.group.set index: [0, 2, 1]
      @v.group.value.should eql ['tomato']
    end

    it 'set by label string' do
      @v.group.set label: 'Tomato'
      @v.group.value.should eql ['tomato']
    end

    it 'set by label regexp' do
      @v.group.set label: /umber/
      @v.group.value.should eql ['cucumber']
    end


    it 'set by index array string, regex' do
      @v.group.set label: ['Cucumber', /mato/]
      @v.group.value.should eql ['tomato']
    end

    it 'options' do
      @v.group.options.should eql ["cucumber", "tomato", "other"]
    end

  end

end