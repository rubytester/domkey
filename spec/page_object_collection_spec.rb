require 'spec_helper'

describe Domkey::View::PageObjectCollection do

  before :all do
    goto_html("test.html")
  end

  it 'init error' do
    # TODO. tighter scope what can be a package
    expect { Domkey::View::PageObjectCollection.new 'foo' }.to raise_error(Domkey::Exception::Error, /package must be kind of hash, watirelement or pageobject/)
  end

  context 'when container is browser by default' do

    context 'package is package defining collection' do

      before :each do
        # package is definition of watir collection
        # package when instantiated must respond to :each
        # test sample:
        # we have 3 text_fields with class that begins with street
        @cbs = Domkey::View::PageObjectCollection.new -> { text_fields(class: /^street/) }
      end

      it 'count or size' do
        expect(@cbs.count).to be(3)
      end

      it 'each returns PageObject' do
        @cbs.each do |e|
          expect(e).to be_a(Domkey::View::PageObject)
        end
      end

      it 'by index returns PageObject' do
        expect(@cbs[0]).to be_a(Domkey::View::PageObject)
        expect(@cbs[0]).to be_a(Domkey::View::PageObject)
      end

      it 'find_all example' do
        # find_all of some condition
        expect(@cbs.find_all { |e| e.value == 'hello pageobject' }).to be_empty
        @cbs.first.set 'hello pageobject'

        # find_all returns the one we just set
        expect(@cbs.find_all { |e| e.value == 'hello pageobject' }.count).to be(1)
      end

      it 'set one and map all example' do
        # set value to later return
        @cbs[1].set 'bye bye'

        # map iterates and harvests value
        expect(@cbs.map { |e| e.value }).to eq ["hello pageobject", "bye bye", ""]
      end

      it 'element reaches to widgetry' do
        expect(@cbs.element).to be_a(Watir::TextFieldCollection)
      end

    end

    context 'package is hash' do

      before :all do
        # would we do that? give me all text_fields :street and all text_fields :city ? in one collection?
        # it becomes a keyed collection?
        # secondary usage
        # given I have city 4 and street 3 textfields
        expect(Domkey.browser.text_fields(class: /^street/).count).to be(3)
        expect(Domkey.browser.text_fields(class: /^city/).count).to be(4)

        # when I define my keyed collection
        hash = {street: -> { text_fields(class: /^street/) },
                city:   -> { text_fields(class: /^city/) }}

        @cbs = Domkey::View::PageObjectCollection.new hash
      end

      it 'count' do
        expect(@cbs.count).to be(2)
      end

      it 'to_a returns array of hashes' do
        expect(@cbs.to_a.count).to be(2)
      end

      it 'each returns hash where value is a PageObjectCollection' do
        @cbs.each do |hash|
          hash.each_pair do |k, v|
            expect(k).to be_a(Symbol)
            expect(v).to be_a(Domkey::View::PageObjectCollection)
          end
        end
      end

      it 'by index returns hash' do
        expect(@cbs.to_a[0]).to be_a(Hash)
      end

      it 'each in key returns PageObject' do
        collection = @cbs.to_a.find { |e| e[:street] }
        expect(collection[:street]).to be_a(Domkey::View::PageObjectCollection)

        collection[:street].each do |e|
          expect(e).to be_a(Domkey::View::PageObject)
        end
      end

      it 'element' do
        expect(@cbs.element :street).to be_a(Watir::TextFieldCollection)
        expect(@cbs.element).to be_a(Hash)
        @cbs.element.each_pair do |k, v|
          expect(k).to be_a(Symbol)
          expect(v).to be_a(Watir::TextFieldCollection)
        end
      end

    end

    context 'package is pageobjectcollection' do

      it 'initialize' do
        pageobjectcollection = Domkey::View::PageObjectCollection.new(-> { text_fields(class: /^street/) })
        @cbs                 = Domkey::View::PageObjectCollection.new pageobjectcollection
      end

    end
  end

end