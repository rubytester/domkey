require 'spec_helper'

describe Domkey::View do

  class SingleDom
    include Domkey::View
    dom(:street) { text_field(class: 'street1') }

    def container
      SingleDomContainer.new browser.div(id: 'container')
    end
  end

  class SingleDomContainer
    include Domkey::View
    dom(:street) { text_field(class: 'street1') }
  end

  before :all do
    goto_html("test.html")
  end

  it 'dom single element' do
    view = SingleDom.new
    view.should respond_to(:street)
    view.street.should be_kind_of(Domkey::View::PageObject)
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
#  goto_html("test.html")
#  view = DomkeyExample::SingleDom.new Domkey.browser
#  bm.report('domkey') do
#    howmany.times do
#      view.street.set 'value'
#      view.street.value
#    end
#  end
#  bm.report('watir-') do
#    howmany.times do
#      Domkey.browser.text_field(class: 'street1').set 'value'
#      Domkey.browser.text_field(class: 'street1').value
#    end
#  end
#end
