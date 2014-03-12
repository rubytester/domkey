require 'spec_helper'

describe Domkey::View::PageObjectCollection do

  before :all do
    Domkey.browser.goto("file://" + __dir__ + "/html/test.html")
  end

  it 'single watirproc defining collection' do

    # watirproc is now defininig a collection and not a single element
    # we have 3 text_fields with class that begins with street
    # if we define a single element we go boom
    watirproc = lambda { text_fields(class: /^street/) }
    cbs       = Domkey::View::PageObjectCollection.new watirproc

    # count or size
    cbs.count.should == 3

    #each returns PageObject
    cbs.each do |e|
      e.should be_kind_of(Domkey::View::PageObject)
    end

    # PageOobject by index
    cbs[0].should be_kind_of(Domkey::View::PageObject)
    cbs[1].should be_kind_of(Domkey::View::PageObject)

    # find_all of some condition
    cbs.find_all { |e| e.value == 'hello pageobject' }.should be_empty

    cbs.first.set 'hello pageobject'

    # find_all returns the one we just set
    cbs.find_all { |e| e.value == 'hello pageobject' }.count.should eql(1)


    # set value to later return
    cbs[1].set 'bye bye'

    # map iterates and harvests value
    cbs.map { |e| e.value }.should eql ["hello pageobject", "bye bye", ""]
  end

  it 'hash watirprocs' do
    #would we do that? give me all text_fields :street and all text_fields :city ? in one collection?
    #secondary usage
    # given I have city 4 and street 3 textfields
    Domkey.browser.text_fields(class: /^street/).count.should == 3
    Domkey.browser.text_fields(class: /^city/).count.should == 4

    # when I define my keyed collection
    watirproc = {street: lambda { text_fields(class: /^street/) },
                 city:   lambda { text_fields(class: /^city/) }}

    cbs = Domkey::View::PageObjectCollection.new watirproc

    # to_a array array of hashes. Each hash key and value is pageobjectcollection
    cbs.to_a.should have(2).items

    #street: pageobjectcollection
    street_hash = cbs.to_a[0]
    street_hash.should be_kind_of(Hash)
    street_collection = street_hash[:street]
    street_collection.should be_kind_of(Domkey::View::PageObjectCollection)
    streets = street_collection.to_a
    streets.should have(3).items
    streets.each { |e| e.should be_kind_of(Domkey::View::PageObject) }

    # each
    cbs.each do |hash|
      hash.each_pair { |k, v| v.should be_kind_of(Domkey::View::PageObjectCollection) }
    end
  end
end