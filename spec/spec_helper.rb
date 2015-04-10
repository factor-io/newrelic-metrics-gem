require "codeclimate-test-reporter"
require 'rspec'

CodeClimate::TestReporter.start if ENV['CODECLIMATE_REPO_TOKEN']

require_relative '../lib/newrelic-metrics.rb'

RSpec.configure do |c|
  
end