describe "read only elements" do

  before :each do
    goto_html("test.html")
  end

  context 'span' do

    class SpanView
      include Domkey::View
      dom(:spanny) { span(id: 'read_only_span') }
    end

    it 'value' do
      v = SpanView.new
      expect(v.spanny.value).to eq "Text In Span"
      expect(v.value :spanny).to eq spanny: 'Text In Span'
    end
  end
end




