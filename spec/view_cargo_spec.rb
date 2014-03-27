require 'spec_helper'

describe Domkey::View do

  class MyView
    include Domkey::View

    dom(:city) { text_field(id: 'city2') }

    def fruit
      CheckboxGroup.new -> { checkboxes(name: 'fruit') }
    end
  end

  before :each do
    Domkey.browser.goto("file://" + __dir__ + "/html/test.html")
  end

  it 'cargo' do
    model = {city: 'Mordor'}
    view  = MyView.new
    cargo = Domkey::View::Cargo.new view: view, model: model
    cargo.set
    scraped_model = cargo.value
    scraped_model.should eql model
  end

  it 'factory' do
    model               = {city: 'Austin', fruit: ['tomato', 'other']}
    cargo               = MyView.cargo model

    # default values when page loads before setting the values
    default_page_values = {:city=>"class city but div id container", :fruit=>["other"]}
    cargo.value.should eql default_page_values
    cargo.set

    extracted_model = cargo.value
    extracted_model.should eql model

  end

end
