# Domain Specific PageObject for Selenium Watir-Webdriver

PageObject that models specific domain first and browser code second.

Watir-Webdriver is the Bee's Knees! Now with Domain Specific PageObject Factory!

## Usage

Create view class and include Domkey::View. Create page object with factory method :dom or collection with :doms.
Instantiate view class with Watir::Browser and interact with pageobjects in your view. @see spec examples.


## Dev

Run unit tests with `bundle exec rake`.

The tests that use git submodule `watirspec` are in progress. The intention is to show pageobject usage for watirspec files.


