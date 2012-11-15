# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'foreman_god/version'

Gem::Specification.new do |gem|
  gem.name          = "foreman_god"
  gem.version       = ForemanGod::VERSION
  gem.authors       = ["Ralf Kistner"]
  gem.email         = ["ralf@embarkmobile.com"]
  gem.description   = %q{God configuration with Procfiles}
  gem.summary       = %q{Configure God using foreman-style Procfiles.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'foreman'
  gem.add_dependency 'god'
end
