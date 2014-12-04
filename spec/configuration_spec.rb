require 'spec_helper'

describe NewRelicMetrics do
  describe NewRelicMetrics::Configuration do
    before do
      @api_key = ENV['NEWRELIC_API_KEY']
    end

    after do
      NewRelicMetrics.configuration = nil
    end

    it 'can set global config' do
      NewRelicMetrics.configure do |c|
        c.api_key = @api_key
      end

      expect(NewRelicMetrics.configuration.api_key).to eq(ENV['NEWRELIC_API_KEY'])
    end

    it 'can set config using a method' do
      config = NewRelicMetrics::Configuration.new

      config.api_key = @api_key

      expect(config.api_key).to eq(@api_key)
    end

    it 'can set config with a block' do 
      config = NewRelicMetrics::Configuration.new do |c|
        c.api_key = @api_key
      end

      expect(config.api_key).to eq(@api_key)
    end

    it 'can set config with a hash' do 
      config = NewRelicMetrics::Configuration.new(api_key: @api_key)

      expect(config.api_key).to eq(@api_key)
    end
  end  
end