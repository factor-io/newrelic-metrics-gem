require 'spec_helper'

describe NewRelicMetrics do
  describe NewRelicMetrics::Client do
    before do
      @api_key = ENV['NEWRELIC_API_KEY']
      config = NewRelicMetrics::Configuration.new(api_key: @api_key)
      @client = NewRelicMetrics::Client.new(config)
      @app_id = ENV['NEWRELIC_APP_ID']
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

    describe 'Names' do
      it 'throws error if no server or app provided' do
        expect { @client.names }.to raise_error(ArgumentError)
      end

      it 'throws error if both server and app is provided' do
        expect { @client.names server:'foo', application:'bar' }.to raise_error(ArgumentError)
      end

      it 'can get a list of names' do

        list = @client.names application: @app_id

        expect(list).to be_a(Array)

        list.each do |metric|
          expect(metric).to include('name')
          expect(metric['name']).to be_a(String)
          expect(metric).to include('values')
          expect(metric['values']).to be_a(Array)
          expect(metric['values']).to all( be_a(String) )
        end
      end
    end

    describe 'Metrics' do
      it 'validates bad server/application values' do
        expect { @client.metrics }.to raise_error(ArgumentError)
        expect { @client.metrics server:'foo', application:'bar' }.to raise_error(ArgumentError)
      end

      it 'validates bad range values' do
        expect { @client.metrics application: @app_id, range:{fail:'fail me'} }.to raise_error(ArgumentError)
        expect { @client.metrics application: @app_id, range:{to:'now'} }.to raise_error(ArgumentError)
      end

      it 'validates bad metric values' do
        expect { @client.metrics application: @app_id }.to raise_error(ArgumentError)
        expect { @client.metrics application: @app_id }.to raise_error(ArgumentError)
      end

      it 'throws error metrics option is wrong type' do
        expect { @client.metrics application: @app_id, metrics:[] }.to raise_error(ArgumentError)
        expect { @client.metrics application: @app_id, metrics:{'fail'=>'test'} }.to raise_error(ArgumentError)
        expect { @client.metrics application: @app_id, metrics:{'fail'=>[{'fail'=>'this too'}]} }.to raise_error(ArgumentError)
      end

      it 'can get data with range' do
        require 'date'
        data = @client.metrics application: @app_id, metrics: {'Apdex'=>['score']}, range:{from:'24 hours ago'}
        validate_data(data)

        from = DateTime.parse(data['from'])
        to = DateTime.parse(data['to'])

        expect(to.to_date).to eq(Time.now.utc.to_date)
        expect(from.to_date).to eq(Time.now.utc.to_date - 1)
      end

      it 'can get data with summary' do
        data = @client.metrics application: @app_id, metrics: {'Apdex'=>['score']}, summarize: true
        validate_data(data)
      end

      it 'can get current data' do
        data = @client.metrics application: @app_id, metrics: {'Apdex'=>['score']}
        validate_data(data)
      end

      def validate_data(data)
        expect(data).to be_a(Hash)
        expect(data).to include('from')
        expect(data).to include('to')
        expect(data).to include('metrics')
        expect(data['from']).to be_a(String)
        expect(data['to']).to be_a(String)

        expect(data['metrics']).to be_a(Array)
        expect(data['metrics'].count).to be(1)

        metric = data['metrics'].first

        expect(metric).to be_a(Hash)
        expect(metric).to include('name')
        expect(metric).to include('timeslices')
        expect(metric['name']).to eq('Apdex')
        expect(metric['timeslices']).to be_a(Array)

        timeslices = metric['timeslices']

        timeslices.each do |slice|
          expect(slice).to be_a(Hash)
          expect(slice).to include('from')
          expect(slice['from']).to be_a(String)
          expect(slice).to include('to')
          expect(slice['to']).to be_a(String)
          expect(slice).to include('values')
          expect(slice['values']).to be_a(Hash)
          expect(slice['values'].keys.count).to eq(1)
          expect(slice['values'].keys.first).to eq('score')
          expect(slice['values']['score']).to be_a(Float)
        end
      end

    end

  end  
end