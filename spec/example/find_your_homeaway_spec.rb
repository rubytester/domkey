$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rspec'
require 'domkey'

=begin
EXAMPLE:

This is a live website example of developing a Domain Specific Page Object

We are modeling a text field with type ahead on homeaway.com website - a similar behavior can be seen on google.com or bing.com
Start typing a text into a text field and with each character a select list appears prompting you to select an entry filterd by what you have typed in so far.

Let's call this Domain Specific PageObject a TypeAheadTextField

Let's say that this TypeAheadTextFields is a pageobject that is a collaboration of two watir elements:
- text_field were you send some keys. let's call it text :seed
- and for each :seed we grow a selection of entries to pick from. let's call them :leaves to follow the :seed, leaves growing metaphor

To set this object means:
- to :seed it with some text
- and pick an entry in :leaves

To ask for options in this object means:
- to :seed it with some text
- and return the :leaves presented as array of text entries

To ask for value of this object means:
- just return the value of text_field


With the above spec we can develop this Semantic PageObject.
=end


# subclass Domkey::View::PageObject to make your own semantic object
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

  # with each char send keys (a default input strategy)
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


# Optionally register a factory method to construct you Domain Specific PageObject
# this factory method is availabe in the view
# this means that in the View you can build TypeAheadTextField objects using type_ahead_text_field method.
Domkey::View.register_domkey_factory :type_ahead_text_field, TypeAheadTextField

class ExampleView
  include Domkey::View

  dom(:seed) { text_field(id: 'searchKeywords') }
  dom(:leaves) { ul(class_name: "typeahead dropdown-menu") }

  # @return TypeAheadTextField object constructed in this view scope
  def finder
    TypeAheadTextField.new({:seed => seed, :leaves => leaves}, watir_container)
  end

  # optionally construct TypeAheadTextField with factory method you have registered earlier
  type_ahead_text_field :finder_from_factory,
                        seed:   -> { text_field(id: 'searchKeywords') },
                        leaves: -> { ul(class_name: "typeahead dropdown-menu") }
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
    f      = view.finder
    leaves = f.options :seed => 'Austin'

    # expected may change
    # we should get 5 items to select from
    # example:
    #["Austin area, Texas (1681)",
    # "Austin, Texas (1221)",
    # "Austin, Quebec (6)",
    # "Austinmer, Australia (5)",
    # "Austinville, Virginia (2)"]

    expect(leaves.size).to eq 5
    expect(leaves.find { |e| e.match("Austinmer, Australia") }).not_to be_falsey

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


  it "type_ahead_text_field factory method" do
    expect(ExampleView).to respond_to(:type_ahead_text_field)
    expect(ExampleView.new).to respond_to(:finder_from_factory)
  end

  it 'type_ahead_text_field usage' do
    # example leaves options as text
    # ["Poland, Europe (678)",
    #  "Poland, Maine (8)",
    #  "Poland Springs, Maine (3)"]
    payload = view.options :finder_from_factory => {:seed => 'Poland'}
    leaves  = payload[:finder_from_factory]
    expect(leaves.find { |e| e.match("Europe") }).not_to be_falsey
  end

end


# LIVE EXAMPLE

class ArriveDepartDateRange < Domkey::View::PageObject
  package_keys :arrive, :depart, :skipdates
end

class FindYourHomeAwayView
  include Domkey::View
  type_ahead_text_field :area,
                        seed:   -> { text_field(id: 'searchKeywords') },
                        leaves: -> { ul(class_name: "typeahead dropdown-menu") }
  dom(:arrive) { text_field(id: 'mastHeadstartDateInput') }
  dom(:depart) { text_field(id: 'mastHeadendDateInput') }
  dom(:skipdates) { checkbox(name: 'skipDates') }
  select_list(:sleeps) { select_list(name: 'sleepsInput') }


  def submit
    watir_container.a(class_name: 'btn btn-primary btn-large search-btn').click
  end
end

describe FindYourHomeAwayView do

  before :each do
    Domkey.browser.goto "http://homeaway.com"
  end

  it 'payload example' do
    payload = {
        area:   {seed: 'Austin', leaves: {index: 3}},
        arrive: "10/10/1970",
        depart: '10/10/1971',
        sleeps: {text: '4+'}
    }

    view = FindYourHomeAwayView.new
    view.set payload
    view.submit

  end
end