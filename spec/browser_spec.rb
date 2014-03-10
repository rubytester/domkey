#require 'spec_helper'
#
#describe Domkey do
#
#  context 'when no browsers present in the system' do
#
#    before do
#      Domkey.browser = nil
#      @browser       = double('browser')
#      @browser.stub(:exist?).and_return(true)
#      Watir::Browser.should_receive(:new).once.and_return(@browser)
#    end
#
#    after do
#      Domkey.browser.close
#    end
#
#    it '.browser gives us default browser' do
#      b = Domkey.browser
#      b.should eq @browser
#    end
#
#    it 'once we start browser we reuse it' do
#      b  = Domkey.browser
#      b2 = Domkey.browser
#      b.should eql b2
#    end
#  end
#end