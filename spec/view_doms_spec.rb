require 'spec_helper'

describe Domkey::View do

  class DomsExample
    include Domkey::View
    doms(:streets) { text_fields(class: 'street1') }
  end


  before :all do
    Domkey.browser.goto("file://" + __dir__ + "/html/test.html")
  end

  it 'doms collection' do
    view = DomsExample.new
    view.should respond_to(:streets)
    view.streets.should be_kind_of(Domkey::View::PageObjectCollection)
    view.streets.each { |e| e.should be_kind_of(Domkey::View::PageObject) }
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
#  view = DomkeyExample::Doms.new Domkey.browser
#  bm.report('domkey') do
#    howmany.times do
#      view.streets.each { |e| e.set "hello" }
#      view.streets.map { |e| e.value }
#    end
#  end
#  bm.report('watir-') do
#    howmany.times do
#      Domkey.browser.text_fields(class: 'street1').each { |e| e.set "hello" }
#      Domkey.browser.text_field(class: 'street1').map { |e| e.value }
#    end
#  end
#end
