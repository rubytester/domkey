require 'spec_helper'

describe Domkey::Page::PageObjectCollection do

  before :all do
    Domkey.browser.goto("file://" + __dir__ + "/html/test.html")
  end


  before :all do
    @container = lambda { Domkey.browser }
  end

  context 'examples using browser' do

    before :all do

      # watirproc is now defininig a collection and not a single element
      # we have 3 text_fields with class that begins with street
      # if we define a single element we go boom
      watirproc = lambda { text_fields(class: /^street/) }
      @cbs      = Domkey::Page::PageObjectCollection.new watirproc, @container
    end

    it 'count' do
      # count or size
      @cbs.count.should == 3
    end

    it 'query each is PageObject' do
      #each returns PageObject
      @cbs.each do |e|
        e.should be_kind_of(Domkey::Page::PageObject)
      end
    end

    it 'query by [index]' do
      # PageOobject by index
      @cbs[0].should be_kind_of(Domkey::Page::PageObject)
      @cbs[1].should be_kind_of(Domkey::Page::PageObject)
    end

    it 'find_all and changing condition' do

      # find_all of some condition
      @cbs.find_all { |e| e.value == 'hello pageobject' }.should be_empty

      @cbs.first.set 'hello pageobject'

      # find_all returns the one we just set
      @cbs.find_all { |e| e.value == 'hello pageobject' }.count.should eql(1)


      # set value to later return
      @cbs[1].set 'bye bye'

      # map iterates and harvests value
      @cbs.map { |e| e.value }.should eql ["hello pageobject", "bye bye", ""]

    end
  end

end


