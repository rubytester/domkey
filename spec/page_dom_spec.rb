require 'spec_helper'
module DomkeyExample

  class SingleDom
    include Domkey::Page
    dom(:street) { text_field(class: 'street1') }

    def container
      SingleDomContainer.new browser.div(id: 'container')
    end
  end

  class SingleDomContainer
    include Domkey::Page
    dom(:street) { text_field(class: 'street1') }
  end

end

describe Domkey::Page do

  before :all do
    Domkey.browser.goto("file://" + __dir__ + "/html/test.html")
  end

  it 'dom single element' do
    view = DomkeyExample::SingleDom.new
    view.should respond_to(:street)
    view.street.should be_kind_of(Domkey::Page::PageObject)
    view.street.value.should == ''
    view.street.set 'bla'
    view.street.value.should == 'bla'
    view.container.street.value.should == ''
    view
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
