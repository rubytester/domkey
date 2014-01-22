require 'spec_helper'

describe Domkey do

  context 'when no browsers present in the system' do

    before do
      Domkey.browser = nil
    end

    it '.browser gives us default browser' do
      b = Domkey.browser
    end

    it 'once we start browser we reuse it' do
      b = Domkey.browser
      b.should be_kind_of(Watir::Browser)
    end

  end


end