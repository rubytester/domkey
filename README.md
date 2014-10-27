# Domain Specific PageObject for Selenium Watir-Webdriver

PageObject that models specific domain first and browser code second.

Watir-Webdriver is the Bee's Knees! Now with Domain Specific PageObject Factory!

# Usage

Create your view class and include Domkey::View. Your class can now be instantiated with Watir Element as a container for page objects. Your view becomes a Page or some part of a page depending on what Watir Element was used to provide the container.


```ruby
class MyPage
  include Domkey::View
end

# Example: if you instantiate your page with Watir::Browser your view scope is for the entire DOM. PageObjects can live anywhere on the page.
MyPage.new(browser)

# Example: if you instantiate your page with portion of DOM you limit the view scope where page objects can be found.
MyPage.new(browser.div(id: 'somediv'))
```

## Simple PageObject

Let's introduce simple wrappers around watir elements first. Later those simple elements will be used to create Domain Specific PageObject behavior.

Indicate what PageObject you have in the view: Create pageobject with factory methods

- `dom`: creates a facade to a watir element definition
- `radio_group`: a facade to a collection of radios with the same name treating them as one pageobject
- `checkbox_group`: like radio_group but for checkboxes collection
- `select_list`: wrapper for Watir::SelectList
- `doms`: collection of watir elements

Example:

```ruby
class MyPage
  include Domkey::View
  dom(:first_name) { text_field(id: 'f_name') }
  dom(:last_name) { text_field(id: 'f_name') }
  domkey :billing_name, first_name: first_name, last_name: last_name
  radio_group(:fruit) { radios(name: 'fruit') }
end
```

Interacting with PageObjects:

PageObject is an object that responds to :set, :value and :options.

- You can interact with it directly, checking its presence, sending data to it or quering it for the current value or options.
- Orr you can send data payload to view which will set the pageobject with desired value

```ruby
page = MyPage.new
page.set :fruit => "atomato"
```

The above will set the radio with value 'atomato' in 'fruit' radio_group

```ruby
page = MyPage.new
page.set :fruit => {label: "Tomato"}
```

The above will also set the radio but the one that has corresponing visible label for radio in a radio_group

Payload is a simple hash object, similar to json structure

## Domain Specific PageObject

Simple wrappers around watir elements are a bit too simplistic way to abstract your application. Apps today use a collaboration of visual elements to make a cohenrent behavior at a higher level than single elements. For example a pageobject like TypeAheadTextField could be a type of object to model the way you type google queries. You enter some text in a text_field and you end up being presented with something that acts like a select_list but in fact is a div with ul playing a role of a listbox
You can model that with Domkey::View::PageObject as a single unit encapsulating the interaction with this thing we may call TypeAheadTextField

Example: would be nice here

## Dev

Run unit tests with `bundle exec rake`.

The tests that use git submodule `watirspec` are in progress. The intention is to show pageobject usage for watirspec files.


