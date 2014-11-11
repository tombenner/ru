require File.expand_path('../lib/rushed/version', __FILE__)

Gem::Specification.new do |s|
  s.authors       = ['Tom Benner']
  s.email         = ['tombenner@gmail.com']
  s.description = s.summary = %q{Ruby in your shell!}
  s.homepage      = 'https://github.com/tombenner/rushed'

  s.files         = `git ls-files`.split($\)
  s.name          = 'rushed'
  s.executables   = ['ru']
  s.require_paths = ['lib']
  s.version       = Rushed::VERSION
  s.license       = 'MIT'

  s.add_dependency 'activesupport'

  s.add_development_dependency 'rspec'
end
