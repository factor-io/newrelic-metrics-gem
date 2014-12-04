require "codeclimate-test-reporter"
require 'rspec'

require_relative '../lib/newrelic-metrics.rb'

CodeClimate::TestReporter.start if ENV['CODECLIMATE_REPO_TOKEN']

RSpec.configure do |c|
  
end