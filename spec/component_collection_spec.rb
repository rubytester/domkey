describe Domkey::View::ComponentCollection do

  before :all do
    goto_html("test.html")
  end

  it 'init error' do
    # TODO. tighter scope what can be a package
    expect { Domkey::View::ComponentCollection.new 'foo' }.to raise_error(Domkey::Exception::Error, /package must be kind of hash, watirelement or page_component/)
  end

  context 'when container is browser by default' do

    context 'package is package defining collection' do

      before :each do
        # package is definition of watir collection
        # package when instantiated must respond to :each
        # test sample:
        # we have 3 text_fields with class that begins with street
        @cbs = Domkey::View::ComponentCollection.new -> { text_fields(class: /^street/) }
      end

      it 'count or size' do
        expect(@cbs.count).to be(3)
      end

      it 'each returns Component' do
        @cbs.each do |e|
          expect(e).to be_a(Domkey::View::Component)
        end
      end

      it 'by index returns Component' do
        expect(@cbs[0]).to be_a(Domkey::View::Component)
        expect(@cbs[0]).to be_a(Domkey::View::Component)
      end

      it 'find_all example' do
        # find_all of some condition
        expect(@cbs.find_all { |e| e.value == 'hello page_component' }).to be_empty
        @cbs.first.set 'hello page_component'

        # find_all returns the one we just set
        expect(@cbs.find_all { |e| e.value == 'hello page_component' }.count).to be(1)
      end

      it 'set one and map all example' do
        # set value to later return
        @cbs[1].set 'bye bye'

        # map iterates and harvests value
        expect(@cbs.map { |e| e.value }).to eq ["hello page_component", "bye bye", ""]
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

        @cbs = Domkey::View::ComponentCollection.new hash
      end

      it 'count' do
        expect(@cbs.count).to be(2)
      end

      it 'to_a returns array of hashes' do
        expect(@cbs.to_a.count).to be(2)
      end

      it 'each returns hash where value is a ComponentCollection' do
        @cbs.each do |hash|
          hash.each_pair do |k, v|
            expect(k).to be_a(Symbol)
            expect(v).to be_a(Domkey::View::ComponentCollection)
          end
        end
      end

      it 'by index returns hash' do
        expect(@cbs.to_a[0]).to be_a(Hash)
      end

      it 'each in key returns Component' do
        collection = @cbs.to_a.find { |e| e[:street] }
        expect(collection[:street]).to be_a(Domkey::View::ComponentCollection)

        collection[:street].each do |e|
          expect(e).to be_a(Domkey::View::Component)
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

    context 'package is page_componentcollection' do

      it 'initialize' do
        page_componentcollection = Domkey::View::ComponentCollection.new(-> { text_fields(class: /^street/) })
        @cbs                 = Domkey::View::ComponentCollection.new page_componentcollection
      end

    end
  end

end