# OptionSelectable object is an object that responds to options and is selectable by its options
# RadioGroup, SelectList, CheckboxGroup.
# CheckboxGroup acts like Multi Select
# RadioGroup acts like Single Select
# SelectList acts like multi or single
describe Domkey::View::CheckboxGroup do

  class CheckboxGroupExampleView
    include Domkey::View
    checkbox_group(:group) { checkboxes(name: 'fruit') }
    checkbox_group(:not_valid_group) { checkboxes(name: /^fruit/) }
  end

  before :each do
    goto_html('test.html')

    @v = CheckboxGroupExampleView.new

    # precondition on distinct group
    expect(@v.group.size).to eq(3)
    @v.group.to_a.each do |e|
      expect(e).to be_a(Domkey::View::Component)
    end
    # clear all selections first
    @v.group.set false
  end

  it 'should fail when group defintion finds 2 distinct groups' do
    v = CheckboxGroupExampleView.new
    expect { v.not_valid_group.to_a }.to raise_error(Domkey::Exception::Error, /definition scope too broad: Found 2 radio groups/)
  end

  it 'set string' do
    @v.group.set 'tomato'
    expect(@v.group.value).to eq ['tomato']
  end

  it 'view set string' do
    @v.set group: 'tomato'
    expect(@v.value :group).to eq group: ['tomato']
  end

  it 'set regexp' do
    @v.group.set /^othe/
    expect(@v.group.value).to eq ['other']
  end

  it 'view set regexp' do
    @v.set group: /^othe/
    expect(@v.value :group).to eq group: ['other']
  end

  it 'set by not implemented symbol' do
    expect { @v.group.set :hello_world }.to raise_error(Domkey::Exception::NotImplementedError)
  end

  it 'set appends by default' do
    @v.group.set 'tomato'
    expect(@v.group.value).to eq ['tomato']

    @v.group.set 'other'
    expect(@v.group.value).to eq ['tomato', 'other']

    @v.group.set false
    expect(@v.group.value).to eq []
  end

  it 'set array of strings or regexp' do
    @v.group.set ['tomato']
    expect(@v.group.value).to eq ['tomato']

    @v.group.set ['other', /tomat/]
    expect(@v.group.value).to eq ['tomato', 'other']
  end

  it 'view set array of strings or regexp' do
    @v.set group: ['tomato']
    expect(@v.value :group).to eq group: ['tomato']

    @v.set group: ['other', /tomat/]
    expect(@v.value :group).to eq group: ['tomato', 'other']
  end

  it 'set false clears all' do
    @v.group.set ['tomato']
    @v.group.set false
    expect(@v.group.value).to eq []
  end

  it 'view set false clears all' do
    @v.set group: ['tomato']
    expect(@v.value :group).to eq group: ["tomato"]
    @v.set group: false
    expect(@v.value :group).to eq group: []
  end

  it 'set true enables all' do
    expect(@v.group.set(true)).to_not be_empty
    expect(@v.group.value).to eq ['cucumber', 'tomato', 'other']
  end

  it 'view set true enables all' do
    @v.set group: true
    expect(@v.value :group).to eq group: ["cucumber", "tomato", "other"]
  end

  it 'set empty array should be noop' do
    @v.set group: ['tomato']
    @v.group.set []
    expect(@v.group.value).to eq ["tomato"]
  end

  it 'set value string not found error' do
    expect { @v.group.set 'toma' }.to raise_error(Domkey::Exception::NotFoundError)
  end

  it 'set value regexp not found error' do
    expect { @v.group.set /balaba/ }.to raise_error(Domkey::Exception::NotFoundError)
  end

  it 'options by default' do
    expect(@v.group.options).to eq ['cucumber', 'tomato', 'other']
  end


  context "using OptionSelectable qualifiers" do

    it 'set by position index single' do
      @v.group.set index: 1
      expect(@v.group.value).to eq ['tomato']
    end

    it 'set by position index array' do
      @v.group.set index: [0, 2, 1]
      expect(@v.group.value).to eq ['cucumber', 'tomato', 'other']
    end

    it 'view set by position index array' do
      @v.set group: {index: [0, 2, 1]}
      expect(@v.value :group).to eq group: ['cucumber', 'tomato', 'other']
    end

    it 'set by label string' do
      @v.group.set label: 'Tomatorama'
      expect(@v.group.value).to eq ['tomato']
    end

    it 'set by label regexp' do
      @v.group.set label: /umberama/
      expect(@v.group.value [:index, :value, :text, :label]).to eq :index => [0], :value => ["cucumber"], :text => ["Cucumberama"], :label => ["Cucumberama"]
    end

    it 'set by index array string, regex' do
      @v.group.set label: ['Cucumberama', /atorama/], index: 2
      expect(@v.group.value).to eq ['cucumber', 'tomato', 'other']
    end

    it 'view set by index array string, regex' do
      @v.set group: {label: ['Cucumberama', /atorama/], index: 2}
      expect(@v.value :group).to eq group: ['cucumber', 'tomato', 'other']
      expect(@v.value group: [:label, :index]).to eq :group => {:label => ["Cucumberama", "Tomatorama", "Other"], :index => [0, 1, 2]}
    end

    it 'value options single selected' do
      @v.group.set [/tomat/]
      expect(@v.group.value).to eq ['tomato']

      expect(@v.group.value :label).to eq :label => ['Tomatorama']
      expect(@v.group.value :label, :value, :index).to eq :label => ['Tomatorama'], :value => ['tomato'], :index => [1]
    end

    it 'value options many selected' do
      @v.group.set ['other', /tomat/, /cucum/]
      expect(@v.group.value).to eq ['cucumber', 'tomato', 'other']

      expect(@v.group.value :label).to eq :label => ['Cucumberama', 'Tomatorama', 'Other']

      expect(@v.group.value :label, :index, :value).to eq :label => ["Cucumberama", "Tomatorama", "Other"], :index => [0, 1, 2], :value => ["cucumber", "tomato", "other"]
    end

    it 'value options none selected' do
      @v.group.set []
      expect(@v.group.value).to eq []
      expect(@v.group.value :label).to eq :label => []
      expect(@v.group.value :label, :index, :value).to eq :label => [], :index => [], :value => []
    end

    it 'options by opts single' do
      v = [{:value => 'cucumber'}, {:value => 'tomato'}, {:value => 'other'}]
      expect(@v.group.options :value).to eq v
      expect(@v.group.options [:value]).to eq v
    end

    it 'options by label' do
      v = [{:label => 'Cucumberama'}, {:label => 'Tomatorama'}, {:label => 'Other'}]
      expect(@v.group.options :label).to eq v
      expect(@v.group.options [:label]).to eq v
    end

    it 'options by opts many' do
      v = [{:value => 'cucumber', :index => 0, :label => 'Cucumberama', :text => 'Cucumberama'},
           {:value => 'tomato', :index => 1, :label => 'Tomatorama', :text => 'Tomatorama'},
           {:value => 'other', :index => 2, :label => 'Other', :text => 'Other'}]

      expect(@v.group.options :value, :index, :label, :text).to eq v
      expect(@v.group.options [:value, :index, :label, :text]).to eq v
    end

    it 'set by unimplmemented qualifier' do
      expect { @v.group.set :hello_world => 'hello world' }.to raise_error(Domkey::Exception::NotImplementedError, /Unknown option qualifier/)
    end

    it 'value by unimplmented qualifier' do
      @v.group.set true
      expect { @v.group.value :hello_world => 'hello world' }.to raise_error(Domkey::Exception::NotImplementedError, /Unknown option qualifier/)
    end

  end
end
