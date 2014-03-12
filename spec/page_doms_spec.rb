require 'spec_helper'
module DomkeyExample
  class Doms
    include Domkey::Page
    doms(:streets) { text_fields(class: 'street1') }
  end
end

describe Domkey::Page do

  before :all do
    Domkey.browser.goto("file://" + __dir__ + "/html/test.html")
  end

  it 'doms collection' do
    view = DomkeyExample::Doms.new
    view.should respond_to(:streets)
    view.streets.should be_kind_of(Domkey::Page::PageObjectCollection)
    view.streets.each { |e| e.should be_kind_of(Domkey::Page::PageObject) }
    view.streets.should_not respond_to(:value) # or should it?
    view.streets.should_not respond_to(:set) # or should it?


    # talk to the browser
    view.streets.each { |e| e.set "hello" }
    view.streets.map { |e| e.value }.should eql ["hello", "hello", "hello"]
  end

end

#require 'benchmark'
#Benchmark.bm do |bm|
#  howmany = 50
#  # setup browser
#  Domkey.browser.goto("file://" + __dir__ + "/html/test.html")
#  page = DomkeyExample::SingleDom.new Domkey.browser
#  bm.report('domkey') do
#    howmany.times do
#      page.street.set 'value'
#      page.street.value
#    end
#  end
#  bm.report('watir-') do
#    howmany.times do
#      Domkey.browser.text_field(class: 'street1').set 'value'
#      Domkey.browser.text_field(class: 'street1').value
#    end
#  end
#end
