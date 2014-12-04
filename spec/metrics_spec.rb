require 'spec_helper'

describe NewRelicMetrics do
  describe NewRelicMetrics::Client do
    before do
      @api_key = ENV['NEWRELIC_API_KEY']
    end

    describe 'Initialization' do
      it 'can throws if no API Key set' do
        
        expect { NewRelicMetrics::Client.new }.to raise_error(ArgumentError)

      end

      it 'can initialize with a config class' do
        config = NewRelicMetrics::Configuration.new(api_key: @api_key)
        expect { NewRelicMetrics::Client.new(config) }.not_to raise_error        
      end
    end
  end  
end