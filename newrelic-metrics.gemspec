# encoding: UTF-8
$LOAD_PATH.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name          = 'newrelic-metrics'
  s.version       = '0.1.02'
  s.platform      = Gem::Platform::RUBY
  s.authors       = ['Maciej Skierkowski']
  s.email         = ['maciej@factor.io']
  s.homepage      = 'https://factor.io'
  s.summary       = 'Easily get metrics out of New Relic for your application or servers'
  s.files         = Dir.glob('lib/*.rb')
  
  s.require_paths = ['lib']

  s.add_runtime_dependency 'rest-client', '~> 1.7.2'
  s.add_runtime_dependency 'chronic', '~> 0.10.2'
  s.add_runtime_dependency 'json', '~> 1.8.1'

  s.add_development_dependency 'codeclimate-test-reporter', '~> 0.3.0'
  s.add_development_dependency 'rspec', '~> 3.1.0'
  s.add_development_dependency 'rake', '~> 10.3.2'
end