require File.expand_path('../lib/ru/version', __FILE__)

Gem::Specification.new do |s|
  s.authors       = ['Tom Benner']
  s.email         = ['tombenner@gmail.com']
  s.description = s.summary = %q{Ruby in your shell!}
  s.homepage      = 'https://github.com/tombenner/ru'

  s.files         = `git ls-files`.split($\)
  s.name          = 'ru'
  s.executables   = ['ru']
  s.require_paths = ['lib']
  s.version       = Ru::VERSION
  s.license       = 'MIT'

  s.add_dependency 'activesupport', '>= 3.2.0'

  s.add_development_dependency 'appraisal', '~> 1.0'
  s.add_development_dependency 'rspec', '~> 3.1'
end
