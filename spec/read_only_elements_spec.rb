require 'spec_helper'

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
      v.spanny.value.should eql "Text In Span"
      v.value(:spanny).should eql spanny: 'Text In Span'
    end
  end
end




