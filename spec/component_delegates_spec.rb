# methods each page_component should have
# set value options elements

describe Domkey::View::Component do

  before :all do
    goto_html("test.html")
  end

  context 'wrapping single watir elements' do

    context 'dispatcher bridges set value and options messages' do

      it 'select' do
        o = Domkey::View::Component.new -> { select_list(id: 'fruit_list') }
        o.set 'Tomato'
        expect(o.value).to eq 'tomato'
      end

    end

    context 'delegate unimplmemented messages' do

      before :all do
        @o = Domkey::View::Component.new -> { text_field(id: 'city1') }
      end

      it 'should delegate to element when element responds' do
        expect(@o).to respond_to(:id)
        expect(@o.id).to eq 'city1'

        expect(@o).to respond_to(:click)
        @o.click
      end

      it 'should not delegate to element when element does not repsond' do
        expect(@o).to_not respond_to(:textaramabada)
        expect { @o.textaramabada }.to raise_error(NoMethodError)
      end
    end

  end

  context 'wrapping hash of elements' do

    before :all do
      @o = Domkey::View::Component.new city: -> { text_field(id: 'city1') }, notthere: -> { 'bad not there element' }
    end

    it 'should delegate to element in first key' do
      expect(@o).to respond_to(:id)
      expect(@o.id).to eq 'city1'

      expect(@o).to respond_to(:click)
      @o.click
    end

  end
end
