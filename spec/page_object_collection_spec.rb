require 'spec_helper'

module Domkey

  module Page

    class PageObjectCollection < PageObject
      include Enumerable


      def each
        instantiator.each do |e|
          yield PageObject.new(lambda { e }, @container)
        end
      end

      def [] i
        to_a[i]
      end

      alias_method :size, :count

      # ---------------- this is only for pageobject

      def set
        fail
      end

      def value
        fail
      end

      def element
        fail
      end

    end
  end
end


describe Domkey::Page::PageObjectCollection do

  before :all do
    Domkey.browser.goto("file://" + __dir__ + "/html/test.html")
  end


  before :all do
    @container = lambda { Domkey.browser }
  end

  it 'of one elment' do
    # watirproc is now defininig a collection
    watirproc = lambda { text_fields(class: /^street/) }

    cbs = Domkey::Page::PageObjectCollection.new watirproc, @container

    cbs.count.should == 3

    cbs.each do |e|
      e.should be_kind_of(Domkey::Page::PageObject)
    end

    # index
    cbs[0].should be_kind_of(Domkey::Page::PageObject)
    cbs[1].should be_kind_of(Domkey::Page::PageObject)

    # find_all
    cbs.find_all { |e| e.value == 'hello pageobject' }.should be_empty

    cbs.first.set 'hello pageobject'

    cbs.find_all { |e| e.value == 'hello pageobject' }.count.should eql(1)

    cbs[1].set 'bye bye'

    cbs.map { |e| e.value }.should eql ["hello pageobject", "bye bye", ""]

  end


end


