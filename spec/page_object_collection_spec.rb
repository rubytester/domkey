require 'spec_helper'

describe Domkey::View::PageObjectCollection do

  before :all do
    goto_html("test.html")
  end

  it 'init error' do
    # TODO. tighter scope what can be a package
    expect { Domkey::View::PageObjectCollection.new 'foo' }.to raise_error(Domkey::Exception::Error)
  end

  context 'when container is browser by default' do

    context 'package is package defining collection' do

      before :each do
        # package is definition of watir collection
        # package when instantiated must respond to :each
        # test sample:
        # we have 3 text_fields with class that begins with street
        package = lambda { text_fields(class: /^street/) }

        @cbs = Domkey::View::PageObjectCollection.new package
      end

      it 'count or size' do
        @cbs.count.should == 3
      end

      it 'each returns PageObject' do
        @cbs.each do |e|
          e.should be_kind_of(Domkey::View::PageObject)
        end
      end

      it 'by index returns PageObject' do
        @cbs[0].should be_kind_of(Domkey::View::PageObject)
        @cbs[1].should be_kind_of(Domkey::View::PageObject)
      end

      it 'find_all example' do
        # find_all of some condition
        @cbs.find_all { |e| e.value == 'hello pageobject' }.should be_empty
        @cbs.first.set 'hello pageobject'

        # find_all returns the one we just set
        @cbs.find_all { |e| e.value == 'hello pageobject' }.count.should eql(1)
      end

      it 'set one and map all example' do
        # set value to later return
        @cbs[1].set 'bye bye'

        # map iterates and harvests value
        @cbs.map { |e| e.value }.should eql ["hello pageobject", "bye bye", ""]
      end

      it 'element reaches to widgetry' do
        @cbs.element.should be_kind_of(Watir::TextFieldCollection)
      end

    end

    context 'package is hash' do

      before :all do
        # would we do that? give me all text_fields :street and all text_fields :city ? in one collection?
        # it becomes a keyed collection?
        # secondary usage
        # given I have city 4 and street 3 textfields
        Domkey.browser.text_fields(class: /^street/).count.should == 3
        Domkey.browser.text_fields(class: /^city/).count.should == 4

        # when I define my keyed collection
        package = {street: lambda { text_fields(class: /^street/) },
                   city:   lambda { text_fields(class: /^city/) }}

        @cbs = Domkey::View::PageObjectCollection.new package
      end

      it 'count' do
        @cbs.count.should == 2
      end

      it 'to_a returns array of hashes' do
        @cbs.to_a.should have(2).items
      end

      it 'each returns hash where value is a PageObjectCollection' do
        @cbs.each do |hash|
          hash.each_pair { |k, v| v.should be_kind_of(Domkey::View::PageObjectCollection) }
        end
      end

      it 'by index returns hash' do
        @cbs.to_a[0].should be_kind_of(Hash)
      end

      it 'each in key returns PageObject' do
        collection = @cbs.to_a.find { |e| e[:street] }
        collection[:street].should be_kind_of(Domkey::View::PageObjectCollection)
        collection[:street].each { |e| e.should be_kind_of(Domkey::View::PageObject) }
      end

      it 'element' do
        @cbs.element(:street).should be_kind_of(Watir::TextFieldCollection)
        @cbs.element.should be_kind_of(Hash)
        @cbs.element.each_pair do |k, v|
          k.should be_a(Symbol)
          v.should be_a(Watir::TextFieldCollection)
        end
      end

    end

    context 'package is pageobjectcollection' do

      it 'initialize' do
        package              = lambda { text_fields(class: /^street/) }
        pageobjectcollection = Domkey::View::PageObjectCollection.new package

        @cbs = Domkey::View::PageObjectCollection.new pageobjectcollection
      end

    end
  end

end