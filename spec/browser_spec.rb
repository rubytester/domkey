require 'spec_helper'

describe Domkey::BrowserSession do

  context 'when no browsers present in the system' do

    it 'browser gives us default browser' do
      #ugly setup with singleton
      Domkey::BrowserSession.instance.browser.close
      Domkey::browser=nil

      fakebrowser = double('browser')
      fakebrowser.stub(:exist?).and_return(true)
      Watir::Browser.should_receive(:new).once.and_return(fakebrowser)
      b = Domkey.browser
      b.should eq fakebrowser
      b2 = Domkey.browser
      b.should eql b2
      Domkey::BrowserSession.instance.browser=nil
    end

  end
end