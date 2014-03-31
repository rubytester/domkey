require 'spec_helper'

describe Domkey::View::RadioGroup do

  class CollectionAsPageObjectGroupView
    include Domkey::View

    # one named radio group
    def tool
      RadioGroup.new -> { radios(name: 'tool') }
    end

    # no good. collection resolves to more than one coherent group
    def two_groups
      RadioGroup.new -> { radios(name: /^tool/) }
    end
  end

  before :all do
    goto_html("test.html")
  end

  it 'two groups example' do
    v = CollectionAsPageObjectGroupView.new
    expect { v.two_groups.to_a.size }.to raise_error
    expect { v.two_groups.map { |e| e } }.to raise_error
    expect { v.two_groups.count }.to raise_error
  end

  it 'one group example' do
    v = CollectionAsPageObjectGroupView.new
    v.tool.count.should == 3
    v.tool.to_a.each { |e| e.should be_kind_of(Domkey::View::PageObject) }
    v.tool.value.should eql 'other'
    v.tool.set 'tomato'
    v.tool.value.should eql 'tomato'
  end
end