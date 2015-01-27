# Domain Specific Page Components for Selenium Watir-Webdriver

Page Components that models specific semantic domain first and browser code second.

Watir-Webdriver is the Bee's Knees! Now with Domain Specific Page Component Factory!

# Usage

Domkey is a library that helps you build Domain Specific Page Components for system testing your application.

Page Component is composed of one or more watir elements. Component models elements as one semantic unit. It is an object that responds to set, value and options as the main way of sending data to it. Component is presented in a container which by default is a Watir::Browser but can be any Watir::Element, or a Component. Components live in a View class which models a page scope, a container in a browser.

Create a view object and include Domkey::View. Now you can create Components in your view.

```ruby
class MyPageView
  include Domkey::View
end
```

Let's say you have a Watir text_field DOM element that means 'First Name' for a customer as a page component. (This is a Simple Component)

```ruby
class MyPageView
  include Domkey::View
  dom(:first_name) { text_field(id: 'fn') }
end
```

View object is instantiated with a browser watir container where page components are present, by default we'll use a `Watir::Browser`, the ulitimate conatiner for all elements. Any Watir::Element can become a container for a Component.

```ruby
view = MyPageView.new
view.first_name #=> returns Component facade encapsulating a text_field
```

There are 2 types of Components that encapuslate interacting with DOM elements:

- Simple Component: a wrapper for a watir element or elements collection.
- Composite Component: domain specific collaboration of several simple watir elements that act as a single semantic unit.

## Simple Component

Simple wrappers for watir elements. Those simple elements will be used to create Domain Specific Component behavior.

Indicate what Component you have in the view using provided factory methods (you can also provide your own factory methods)

- `dom`: builtin factory method that creates a component from a watir element definition (if you don't like the factory method dom you can create a different one)
- `radio_group`: builtin factory method to a collection of radios with the same name treating them as one page_component
- `checkbox_group`: similar to radio_group but for checkboxes as one page_component
- `select_list`: for single and multiselect lists
- `doms`: collection of watir elements

Example:

```ruby
class MyPage
  include Domkey::View
  dom(:first_name) { text_field(id: 'f_name') }
  dom(:last_name) { text_field(id: 'f_name') }
  radio_group(:fruit) { radios(name: 'fruit') }
end
```

## Composite Component

Simple wrappers around watir elements are a bit too simplistic way to abstract your application. Apps today use a collaboration of dom elements to make a coherent behavior at a higher abstraction layer. Essenitally they are no longer html controls but Domain Specific compositions of elements that act as one componet.For example a page_component we might name `TypeAheadTextField` could model a way you type Google search terms or HomeAway vacation rental location; As a user you enter some text in a text_field and you expect to be presented with something that acts like a list of entries to select from. You select one of entries in a list which may trigger the actual search term.

We use Domkey::View::Component to compose a single unit encapsulating the interaction with this thing we named `TypeAheadTextField`. Let's say it needs 2 DOM elements to build a collaboration. An initial text we enter we may call `:seed` text and a list of entries that will sprout with each character you type, let's call that list `:leaves` (see spec/examples/ for more info)

How do you create this Domain Specific Component?

- create a class subclassing from Domkey::View::Component
    - TypeAheadTextField
- optionally provide validation what kind of keys must be present in the package
    - must have keys :seed and :leaves
- Implement 3 methods. :set, :value, :options.
    - you are free to build other behavior into your object with your messages.
- register factory method in your view that creates your type of Component
    - for this example let's say `:type_ahead_text_field` factory should create TextAheadTextField components

Example: this is how it may look like in code

```ruby
class TextAheadTextField < Domkey::View::Component

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

# and in your view class create a method `finder` as instance of TypeAheadTextField page_component.
class MyPageView
  include Domkey::View
  # example of 2 elements that collaborate
  type_ahead_text_field :finder, seed: -> {text_field(id: 'searchby'}, leaves: -> { ul(id: 'list' }
end
```


## Interacting with Components


- You can interact with page_component directly, checking its presence in the current view, sending data to it or quering it for the current value or options.
- Or you can send data payload to view which will set the page_component with desired value

Payload is a simple hash object, similar to json structure. See examples in spec files.

## Dev

Run unit tests with `bundle exec rake`.
