# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ruby_stix/version'

Gem::Specification.new do |gem|
  gem.name          = "ruby_stix"
  gem.version       = StixRuby::VERSION
  gem.authors       = ["John Wunder"]
  gem.email         = ["jwunder@mitre.org"]
  gem.description   = %q{Bindings and APIs for STIX and CybOX}
  gem.summary       = %q{Bindings and APIs for STIX and CybOX}
  gem.homepage      = ""
  gem.platform      = "java"

  gem.add_development_dependency 'nokogiri'
  gem.add_dependency 'activesupport', '4.0.0'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
