describe Domkey::View do

  class DomsExample
    include Domkey::View
    doms(:streets) { text_fields(class: 'street1') }
  end


  before :all do
    goto_html("test.html")
  end

  it 'doms collection' do
    view = DomsExample.new
    expect(view).to respond_to(:streets)
    expect(view.streets).to be_a(Domkey::View::ComponentCollection)
    view.streets.each do |e|
      expect(e).to be_a(Domkey::View::Component)
    end
    expect(view.streets).to_not respond_to(:value) # or should it?
    expect(view.streets).to_not respond_to(:set) # or should it?


    # talk to the browser
    view.streets.each { |e| e.set "hello" }
    expect(view.streets.map { |e| e.value }).to eq ["hello", "hello", "hello"]
  end

end

#require 'benchmark'
#Benchmark.bm do |bm|
#  howmany = 50
#  # setup browser
#  goto_html("test.html")
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
