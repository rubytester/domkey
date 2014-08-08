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
      # clear all selections first
      @v.group.set false
    end

    it 'set string' do
      @v.group.set 'tomato'
      @v.group.value.should eql ['tomato']
    end

    it 'view set string' do
      @v.set group: 'tomato'
      @v.value(:group).should eql group: ['tomato']
    end

    it 'set regexp' do
      @v.group.set /^othe/
      @v.group.value.should eql ['other']
    end

    it 'view set regexp' do
      @v.set group: /^othe/
      @v.value(:group).should eql(group: ['other'])
    end

    it 'set by not implemented symbol' do
      expect { @v.group.set :hello_world }.to raise_error(Domkey::Exception::NotImplementedError)
    end

    it 'set appends by defulat' do
      @v.group.set 'tomato'
      @v.group.value.should eql ['tomato']
      @v.group.set 'other'
      @v.group.value.should eql ['tomato', 'other']
      @v.group.set false
      @v.group.value.should eql []
    end

    it 'set array of strings or regexp' do
      @v.group.set ['tomato']
      @v.group.value.should eql ['tomato']

      @v.group.set ['other', /tomat/]
      @v.group.value.should eql ['tomato', 'other']
    end

    it 'view set array of strings or regexp' do
      @v.set group: ['tomato']
      @v.value(:group).should eql(group: ['tomato'])

      @v.set group: ['other', /tomat/]
      @v.value(:group).should eql(group: ['tomato', 'other'])
    end

    it 'set false clears all' do
      @v.group.set false
      @v.group.value.should eql []
    end

    it 'set empty array clears all' do
      @v.group.set []
      @v.group.value.should eql []
    end

    it 'set value string not found error' do
      expect { @v.group.set 'toma' }.to raise_error
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
      @v.group.value.should eql ['cucumber', 'tomato', 'other']
    end

    it 'view set by index array' do
      @v.set group: {index: [0, 2, 1]}
      @v.value(:group).should eql(group: ['cucumber', 'tomato', 'other'])
    end

    it 'set by label string' do
      @v.group.set label: 'Tomatorama'
      @v.group.value.should eql ['tomato']
    end

    it 'set by label regexp' do
      @v.group.set label: /umberama/
      @v.group.value([:index, :value, :text, :label]).should eql([{:index => 0, :value => "cucumber", :text => "Cucumberama", :label => "Cucumberama"}])
    end


    it 'set by index array string, regex' do
      @v.group.set label: ['Cucumberama', /atorama/], index: 2
      @v.group.value.should eql ['cucumber', 'tomato', 'other']
    end

    it 'view set by index array string, regex' do
      @v.set group: {label: ['Cucumberama', /atorama/], index: 2}
      @v.value(:group).should eql(group: ['cucumber', 'tomato', 'other'])
      @v.value(group: [:label, :index]).should eql(group: [{label: "Cucumberama", index: 0}, {label: "Tomatorama", index: 1}, {label: "Other", index: 2}])
    end

    it 'value options single selected' do
      @v.group.set [/tomat/]
      @v.group.value.should eql ['tomato']

      @v.group.value(:label).should eql [{:label=>"Tomatorama"}]
      @v.group.value([:label]).should eql [{:label=>"Tomatorama"}]
      @v.group.value(:label, :value, :index).should eql [{:label=>"Tomatorama", :value=>"tomato", :index=>1}]
    end

    it 'value options many selected' do
      @v.group.set ['other', /tomat/, /cucum/]
      @v.group.value.should eql ['cucumber', 'tomato', 'other']

      @v.group.value(:label).should eql [{:label=>"Cucumberama"}, {:label=>"Tomatorama"}, {:label=>"Other"}]
      @v.group.value(:label, :index, :value).should eql [{:label=>"Cucumberama", :index=>0, :value=>"cucumber"},
                                                         {:label=>"Tomatorama", :index=>1, :value=>"tomato"},
                                                         {:label=>"Other", :index=>2, :value=>"other"}]
    end

    it 'value options none selected' do
      @v.group.set []
      @v.group.value.should eql []
      @v.group.value(:label).should eql []
      @v.group.value(:label, :index, :value).should eql []
    end

    it 'options by default' do
      @v.group.options.should eql ["cucumber", "tomato", "other"]
    end

    it 'options by opts single' do
      @v.group.options(:value).should eql [{:value=>"cucumber"}, {:value=>"tomato"}, {:value=>"other"}]
      @v.group.options([:value]).should eql [{:value=>"cucumber"}, {:value=>"tomato"}, {:value=>"other"}]
    end

    it 'options by label' do
      @v.group.options(:label).should eql [{:label=>"Cucumberama"}, {:label=>"Tomatorama"}, {:label=>"Other"}]
      @v.group.options([:label]).should eql [{:label=>"Cucumberama"}, {:label=>"Tomatorama"}, {:label=>"Other"}]
    end

    it 'options by opts many' do
      expected = [{:value=>"cucumber", :index=>0, :label=>"Cucumberama", :text=>"Cucumberama"},
                  {:value=>"tomato", :index=>1, :label=>"Tomatorama", :text=>"Tomatorama"},
                  {:value=>"other", :index=>2, :label=>"Other", :text=>"Other"}]

      @v.group.options(:value, :index, :label, :text).should eql expected
      @v.group.options([:value, :index, :label, :text]).should eql expected
    end
  end
end