require 'spec_helper'

describe Domkey do
  it 'should have a version number' do
    Domkey::VERSION.should_not be_nil
  end

  it 'should start a browser' do
    b = Domkey.browser
  end
end
