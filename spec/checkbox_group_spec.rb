require 'spec_helper'

describe Domkey::View::CheckboxGroup do

  class CollectionAsPageObjectCheckboxGroupView
    include Domkey::View

    def group
      CheckboxGroup.new -> { checkboxes(name: 'fruit') }
    end

    def groups
      CheckboxGroup.new -> { checkboxes(name: /^fruit/) }
    end
  end

  before :all do
    goto_html("test.html")
  end

  it 'two groups example' do
    v = CollectionAsPageObjectCheckboxGroupView.new
    expect { v.groups.to_a.size }.to raise_error
    expect { v.groups.map { |e| e } }.to raise_error
    expect { v.groups.count }.to raise_error
  end

  context "OptionSelectable object multi" do
    # OptionSelectable object is an object that responds to options and is selectable by its optioins;
    # RadioGroup, Select, CheckboxGroup. CheckboxGroup acts like Multi Select, RadioGroup acts like Single Select

    before :each do
      goto_html("test.html")

      @v = CollectionAsPageObjectCheckboxGroupView.new
      @v.group.count.should == 3
      @v.group.to_a.each { |e| e.should be_kind_of(Domkey::View::PageObject) }
    end

    it 'initial value on test page' do
      @v.group.value.should eql ['other']
    end

    it 'set value attribute by default. value returns array of value attribute' do
      @v.group.set 'tomato'
      @v.group.value.should eql ['tomato']
    end

    it 'set array of value attribute. value returns array of value attribute' do
      @v.group.set ['tomato']
      @v.group.value.should eql ['tomato']

      @v.group.set ['other', 'tomato']
      @v.group.value.should eql ['tomato', 'other']
    end

    it 'set false clears all. value is empty array' do
      @v.group.set false
      @v.group.value.should eql []
    end

    it 'set empty array clears all. value is empty array' do
      @v.group.set []
      @v.group.value.should eql []
    end
  end
end