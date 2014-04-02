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

    it 'set value attribute by default. value returns that value attribute' do
      @v.group.set 'tomato'
      @v.group.value.should eql ['tomato']
      @v.group.set /^oth/
      @v.group.value.should eql ['other']
    end

    it 'set array of value attribute. last value wins' do
      @v.group.set ['tomato']
      @v.group.value.should eql ['tomato']

      @v.group.set ['other', 'tomato', /cucu/]
      @v.group.value.should eql ['cucumber']
    end

    it 'set false has no effect. value is initial value on the page' do
      @v.group.set false
      @v.group.value.should eql ['other']
    end

    it 'set empty array clears all. value is empty array' do
      @v.group.set []
      @v.group.value.should eql ['other']
    end

    it 'set value string not found error' do
      expect { @v.group.set 'foobar' }.to raise_error
    end

    it 'set value regexp not found error' do
      expect { @v.group.set /balaba/ }.to raise_error
    end

    it 'options' do
      @v.group.options.should eql ["cucumber", "tomato", "other"]
    end

  end

end