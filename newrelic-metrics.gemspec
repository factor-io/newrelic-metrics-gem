# encoding: UTF-8
$LOAD_PATH.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name          = 'newrelic-metrics'
  s.version       = '0.1.1'
  s.platform      = Gem::Platform::RUBY
  s.authors       = ['Maciej Skierkowski']
  s.email         = ['maciej@factor.io']
  s.homepage      = 'https://factor.io'
  s.summary       = 'Easily get metrics out of New Relic for your application or servers'
  s.files         = Dir.glob('lib/*.rb')
  
  s.require_paths = ['lib']

  s.add_runtime_dependency 'rest-client', '~> 1.8.0'
  s.add_runtime_dependency 'chronic', '~> 0.10.2'
  s.add_runtime_dependency 'json', '~> 1.8.2'

  s.add_development_dependency 'codeclimate-test-reporter', '~> 0.4.7'
  s.add_development_dependency 'rspec', '~> 3.2.0'
  s.add_development_dependency 'rake', '~> 10.4.2'
end