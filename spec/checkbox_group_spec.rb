require 'spec_helper'

describe Domkey::View::CheckboxGroup do

  class CollectionAsPageObjectGroupView
    include Domkey::View

    def one_cb_group
      CheckboxGroup.new -> { checkboxes(name: 'fruit') }
    end

    def two_cb_groups
      CheckboxGroup.new -> { checkboxes(name: /^fruit/) }
    end
  end

  before :all do
    Domkey.browser.goto("file://" + __dir__ + "/html/test.html")
  end

  it 'two groups example' do
    v = CollectionAsPageObjectGroupView.new
    expect { v.two_cb_groups.to_a.size }.to raise_error
    expect { v.two_cb_groups.map { |e| e } }.to raise_error
    expect { v.two_cb_groups.count }.to raise_error
  end

  it 'one group example' do
    v = CollectionAsPageObjectGroupView.new
    v.one_cb_group.count.should == 3
    v.one_cb_group.to_a.each { |e| e.should be_kind_of(Domkey::View::PageObject) }
    v.one_cb_group.value.should eql ['other']
    v.one_cb_group.set 'tomato'
    v.one_cb_group.value.should eql ['tomato']

    v.one_cb_group.set ['tomato']
    v.one_cb_group.value.should eql ['tomato']

    v.one_cb_group.set false
    v.one_cb_group.value.should eql []

    v.one_cb_group.set ['other', 'tomato']
    v.one_cb_group.value.should eql ['tomato', 'other']
  end
end