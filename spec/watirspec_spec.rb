require 'spec_helper'

describe "Watirspec setup for Domkey" do

  before :each do
    goto_watirspec("forms_with_input_elements.html")
  end

  it 'Domkey.browser is browser from watirspec' do
    Domkey.browser.title.should == "Forms with input elements"
  end
end