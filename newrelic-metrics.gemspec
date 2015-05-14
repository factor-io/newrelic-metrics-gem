# encoding: UTF-8
$LOAD_PATH.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name          = 'newrelic-metrics'
  s.version       = '0.1.10'
  s.platform      = Gem::Platform::RUBY
  s.authors       = ['Maciej Skierkowski']
  s.email         = ['maciej@factor.io']
  s.homepage      = 'https://factor.io'
  s.summary       = 'Easily get metrics out of New Relic for your application or servers'
  s.description   = 'This is a Ruby gem to easily get metrics for your application or servers from New Relic using the V2 API. This requires a Pro account.'
  s.files         = Dir.glob('lib/*.rb')
  s.license       = 'MIT'
  s.required_ruby_version = '>= 1.9.2'
  
  s.require_paths = ['lib']

  s.add_runtime_dependency 'rest-client', '~> 1.8', '>= 1.8.0'
  s.add_runtime_dependency 'chronic', '~> 0.10', '>= 0.10.2'
  s.add_runtime_dependency 'json', '~> 1.8', '>= 1.8.2'
  s.add_runtime_dependency 'link_header', '~> 0.0.8'

  s.add_development_dependency 'codeclimate-test-reporter', '~> 0.4.7'
  s.add_development_dependency 'rspec', '~> 3.2.0'
  s.add_development_dependency 'rake', '~> 10.4.2'
  s.add_development_dependency 'link_header', '~> 0.0.8'
end
