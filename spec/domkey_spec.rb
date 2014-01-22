require 'spec_helper'

describe Domkey do
  it 'should have a version number' do
    Domkey::VERSION.should_not be_nil
  end

  it 'should first first' do
    false.should be_true
  end

  it 'should start a browser' do
    b = Watir::Browser.new

  end
end
