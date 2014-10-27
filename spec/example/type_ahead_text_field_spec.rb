$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rspec'
require 'domkey'

# Example: developing a domain specific page object called TypeAheadTextField
# TypeAheadTextFields is a pageobject that is a collaboration of two elements:
# text_field were you send some keys and for each key we display a list of candidates to pick from.
# the original text we "seed" and then look at what options are to pick from. we can call those "leaves"
class TypeAheadTextField < Domkey::View::PageObject

  # @return array of visible text to select from
  def options opts
    set_seed opts[:seed]
    leaves_links.map { |a| a.text }
  end

  # set :seed and select by position with :index or by :text matching (or don't select after seed)
  def set opts
    set_seed opts[:seed]
    # select by :index, :text or don't at select all
    if opts[:index]
      leaves_links[opts[:index]].click
    elsif txt = opts[:text]
      leaves_links.find { |a| a.text.match(txt) }.click
    end
  end

  # just the text in the text_field
  def value
    package[:seed].value
  end

  private

  # with each char send keys default strategy
  def set_seed seed
    package[:seed].element.clear
    seed.each_char do |char|
      package[:seed].element.send_keys char
    end
  end

  # array of links given by the seed
  def leaves_links
    package[:leaves].element.lis.map { |li| li.as.first }
  end
end

class ExampleView
  include Domkey::View

  dom(:seed) { text_field(id: 'searchKeywords') }
  dom(:leaves) { ul(class_name: "typeahead dropdown-menu") }

  def finder
    TypeAheadTextField.new :seed => seed, :leaves => leaves
  end

  # type_ahead_text_field :region,
  #                       seed:   -> { text_field(id: 'searchKeywords') },
  #                       leaves: -> { ul(class_name: "typeahead dropdown-menu") }
end


describe TypeAheadTextField do

  after :each do
    Domkey.browser.close
  end

  before :each do
    Domkey.browser.goto "http://homeaway.com"
  end

  let(:view) { ExampleView.new }

  it "options" do
    f        = view.finder
    leaves   = f.options :seed => 'Austin'

    # expected may change
    expected = ["Austin area, Texas (1681)",
                "Austin, Texas (1221)",
                "Austin, Quebec (6)",
                "Austinmer, Australia (5)",
                "Austinville, Virginia (2)"]
    expect(leaves).to eq expected
  end


  it "set position" do
    f = view.finder
    # setting means providing iniitial seed and selecting second position in leaves collection
    f.set :seed => 'Austin', :index => 1
    expect(f.value).to eq "Austin, Texas"
  end

  it "set text partial" do
    f = view.finder
    # setting means providing initial seed and selecting text that matches provided text
    f.set :seed => 'Austin', :text => "Austinmer"
    expect(f.value).to eq "Austinmer, Australia"
  end


end