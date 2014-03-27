require 'spec_helper'

# methods each pageobject should have
# set value options elements

describe Domkey::View::WatirWidget do

  before :all do
    Domkey.browser.goto("file://" + __dir__ + "/html/test.html")
  end

  context "Watir::Select" do

    context "Single Select List" do

      before :all do
        object  = Domkey.browser.select(id: 'fruit_list')
        @widget = Domkey::View::WatirWidget.new(object)
      end

      it 'text visible to user' do
        @widget.set 'Tomato'
        @widget.value.should == 'Tomato'
      end

      it 'label as text visible to user' do
        @widget.set 'Other'
        @widget.value.should == 'Other' #respect select.value api
      end

      it 'array of text and label' do
        @widget.set ['Other', 'Tomato']
        @widget.value.should eql 'Tomato' # the last one set
      end

    end

  end

end
