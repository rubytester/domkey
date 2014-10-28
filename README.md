# Domain Specific PageObject for Selenium Watir-Webdriver

PageObject that models specific domain first and browser code second.

Watir-Webdriver is the Bee's Knees! Now with Domain Specific PageObject Factory!

# Usage

```ruby
class MyPageView
  include Domkey::View
end
```

Create a view class and include Domkey::View. Now you can create PageObjects in your view. Let's say you have a Watir text_field that means 'First Name' for a customer

```ruby
class MyPageView
  include Domkey::View
  dom(:first_name) { text_field(id: 'fn') }
end
```

Your view needs a watir container in which page objects are scoped to, by default we'll use a Watir Browser. If you instantiate your view with Watir::Browser your view container is for the entire DOM of that browser.

```ruby
view = MyPageView.new
view.first_name #=> should be a PageObject encapsulating a text_field
```

In Domkey you can create two types of PageObjects that encapuslate interacting with dom elements:

- Simple PageObject: just a wrapper for a watir element or colletion of watir elements
- Domain Specific PageObjects: where you model widgets composed of several watir_elements

## Simple PageObject

Let's introduce simple wrappers around watir elements first. Later those simple elements will be used to create Domain Specific PageObject behavior.

Indicate what PageObject you have in the view: Create pageobject with factory methods

- `dom`: creates a facade to a watir element definition
- `radio_group`: a facade to a collection of radios with the same name treating them as one pageobject
- `checkbox_group`: like radio_group but for checkboxes collection
- `select_list`: for single and multiselect lists
- `doms`: collection of watir elements

Example:

```ruby
class MyPage
  include Domkey::View
  dom(:first_name) { text_field(id: 'f_name') }
  dom(:last_name) { text_field(id: 'f_name') }
  domkey :billing_name, first_name: -> { text_field(id: 'f_name') }, last_name: -> { text_field(id: 'f_name') }
  radio_group(:fruit) { radios(name: 'fruit') }
end
```

## Domain Specific PageObject

Simple wrappers around watir elements are a bit too simplistic way to abstract your application. Apps today use a collaboration of visual elements to make a coherent behavior at a higher level than single dom elements. For example a pageobject like TypeAheadTextField could be a type of object to model the way you type google search terms, You enter some text in a text_field and you end up being presented with something that acts like a select_list but in fact is a div with ul playing a role of a listbox.
You can model that Widget using Domkey::View::PageObject as a single unit encapsulating the interaction with this thing we may call TypeAheadTextField (see spec/examples/ for more info)

How do you create a Domain Specific PageObject?
- create a class subclassing from Domkey::View::PageObject.
- Implement 3 methods. :set, :value, :options.
- register factory method in your view that creates your type of Object

```ruby
class TextAheadTextField < Domkey::View::PageObject

  def set *value
    # implement
  end
  def value *opts
    #implement
  end

  def options *opts
    # implement
  end

end
Domkey::View.register_domkey_factory :type_ahead_text_field, TypeAheadTextField

# and in your view class
class MyPageView
  include Domkey::View
  # example of 2 elements that collaborate
  type_ahead_text_field :finder, seed: -> {text_field(id: 'searchby'}, leaves: -> { ul(id: 'list' }
end
```

Please see examples. Actually run examples and specs to see it all work.

## Interacting with PageObjects


- You can interact with pageobject directly, checking its presence, sending data to it or quering it for the current value or options.
- Or you can send data payload to view which will set the pageobject with desired value

Payload is a simple hash object, similar to json structure. See examples in spec files.

## Dev

Run unit tests with `bundle exec rake`.

The tests that use git submodule `watirspec` are in progress. The intention is to show pageobject usage for watirspec files.
