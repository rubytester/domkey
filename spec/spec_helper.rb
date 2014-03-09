$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'domkey'

RSpec.configure do |config|
  config.after :all do
    Domkey.browser.close
  end
end