# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'domkey/version'

Gem::Specification.new do |spec|
  spec.name          = "domkey"
  spec.version       = Domkey::VERSION
  spec.authors       = ["rubytester", "marekj"]
  spec.email         = ["github@rubytester.com"]
  spec.summary       = %q{browser automation selenium-webdriver, watir-webdriver; model view controllers page objects etc...}
  spec.description   = %q{browser automation selenium-webdriver, watir-webdriver; model view controllers page objects etc...}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '~> 2.0'

  spec.add_dependency 'watir-webdriver', '~> 0.6.4'

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 2.14'
  spec.add_development_dependency 'simplecov'

end
