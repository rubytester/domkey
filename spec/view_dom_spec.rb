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

  context 'dom for single element' do

    before :all do
      @view = SingleDom.new
    end

    it 'view responds to dom' do
      @view.should respond_to(:street)
    end

    it 'dom returns PageObject' do
      @view.street.should be_kind_of(Domkey::View::PageObject)
    end

    it 'dom set and value' do
      @view.street.value.should == ''
      @view.street.set 'bla'
      @view.street.value.should == 'bla'
    end
  end

  context 'view method returns view that acts like pageobject' do
    before :all do
      @view = SingleDom.new
    end

    it 'view semantic descriptor returns view' do
      @view.container.should be_kind_of(Domkey::View)
    end

    it 'view within view is a page object' do
      @view.container.street.should be_kind_of(Domkey::View::PageObject)
    end

    it 'value requires args' do
      expect { @view.container.value }.to raise_error
    end

    it 'setting and value args' do
      @view.container.set street: 'Nowy Świat'

      v = @view.container.value :street
      v.should eql({:street=>"Nowy Świat"})

      v = @view.container.value [:street]
      v.should eql({:street=>"Nowy Świat"})
    end
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
