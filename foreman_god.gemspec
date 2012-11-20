# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'foreman_god/version'

Gem::Specification.new do |gem|
  gem.name          = "foreman_god"
  gem.version       = ForemanGod::VERSION
  gem.authors       = ["Ralf Kistner"]
  gem.email         = ["ralf@embarkmobile.com"]
  gem.description   = %q{Monitor Procfiles with God. Mostly compatible with foreman.}
  gem.summary       = %q{Monitor Procfiles with God}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'foreman', '~> 0.60.2'
  gem.add_dependency 'god', '>= 0.12.0'
end
