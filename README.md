# Domain Specific PageObject for Selenium Watir-Webdriver

PageObject that models specific domain first and browser code second.

Watir-Webdriver is the Bee's Knees! Now with Domain Specific PageObject Factory!

# Usage

Domkey is a library that helps you build Domain Specific PageObjects for system testing your application.

PageObject is composed of one or more watir elements and models them as one semantic unit. It is an object that responds to set, value and options as the main way of sending data to it. PageObject is presented in a container which by default is a Watir::Browser but can be any Watir::Element, or PageObject. A collection of PageObjects live in a View class which models a Context.

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

Your view needs a watir container where page objects are present, by default we'll use a `Watir::Browser`, the ulitimate conatiner for all elements. Any Watir::Element can become a container for a PageObject.

```ruby
view = MyPageView.new
view.first_name #=> returns PageObject facade encapsulating a text_field
```

There are 2 types of PageObjects that encapuslate interacting with dom elements:

- Simple PageObject: a wrapper for a watir element or colletion of watir elements
- Domain Specific PageObject: a widgets composed of several Simple PageObjects

## Simple PageObject

Let's introduce simple wrappers around watir elements first. Later those simple elements will be used to create Domain Specific PageObject behavior.

Indicate what PageObject you have in the view using provided factory methods (you can also provide your own factory methods)

- `dom`: creates a facade to a watir element definition (if you don't like the factory method dom you can create a different one)
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

Simple wrappers around watir elements are a bit too simplistic way to abstract your application. Apps today use a collaboration of dom elements to make a coherent behavior at a higher abstraction layer. Essenitally they are no longer html controls but domain specific UI widgets. For example a pageobject we might name `TypeAheadTextField` could model a way you type Google search terms, or Bing search or HomeAway vacation rental city/area; you enter some text in a text_field and you are presented with something that acts like a list of entries to select from.

We can model that Widget using Domkey::View::PageObject as a single unit encapsulating the interaction with this thing we named `TypeAheadTextField`. Let's say it needs 2 dom elements to build a collaboration. An initial text we enter we may call `:seed` text and a liset of entries that will sprout with each char you type, let's call that list `:leaves` (see spec/examples/ for more info)

How do you create this Domain Specific PageObject?
- create a class subclassing from Domkey::View::PageObject
    - TypeAheadTextField
- optionally provide validation what kind of keys must be present in the package
    - must have keys :seed and :leaves
- Implement 3 methods. :set, :value, :options.
    - you are free to build other behavior into your object with your messages.
- register factory method in your view that creates your type of Object
    - for this one let's say `:type_ahead_text_field` factory should create TextAheadTextField objects

Example: this is how it may look like in code

```ruby
class TextAheadTextField < Domkey::View::PageObject

  package_keys :seed, :leaves

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

# and in your view class create a method `finder` as instance of TypeAheadTextField pageobject.
class MyPageView
  include Domkey::View
  # example of 2 elements that collaborate
  type_ahead_text_field :finder, seed: -> {text_field(id: 'searchby'}, leaves: -> { ul(id: 'list' }
end
```

Please see examples. Actually run examples and specs to see it all work.

## Interacting with PageObjects


- You can interact with pageobject directly, checking its presence in the current view, sending data to it or quering it for the current value or options.
- Or you can send data payload to view which will set the pageobject with desired value

Payload is a simple hash object, similar to json structure. See examples in spec files.

## Dev

Run unit tests with `bundle exec rake`.
