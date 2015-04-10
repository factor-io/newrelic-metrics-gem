require 'restclient'
require 'json'
require 'uri'
require 'chronic'

module NewRelicMetrics
  class Configuration
    attr_accessor :api_key
    def initialize(options={},&block)
      @api_key=options[:api_key]
      yield(self) if block
    end
  end

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class RequestFailed < StandardError
  end

  class Client
    BASE = 'https://api.newrelic.com/v2'

    def initialize(config=nil)
      @config = config || NewRelicMetrics.configuration

      raise ArgumentError.new("No API Key is configured") unless @config && @config.api_key
    end

    def names(options={})
      validate_resource_options(options)
      resource_id = options[:application] || options[:server]
      resource    = options[:application] ? 'applications' : 'servers'
      
      get(resource, resource_id, "metrics")['metrics']
    end

    def metrics(options={})
      validate_metric_options(options)
      resource_id = options[:application] || options[:server]
      resource    = options[:application] ? 'applications' : 'servers'
      query       = generate_metrics_query(options)

      get(resource, resource_id, "metrics/data", query)['metric_data']
    end

    private

    def generate_metrics_query(options={})
      summarize   = options[:summarize] || false
      metrics     = options[:metrics]
      range       = options[:range] || {}
      conditions  = []

      metrics.keys.each {|name| conditions << "names[]=#{URI.encode(name)}" }
      metrics.values.flatten.each {|val| conditions << "values[]=#{URI.encode(val)}" }

      if range[:from]
        from_time = range[:from].is_a?(String) ? Chronic.parse(range[:from], context: :past) : range[:from]
        to_time = range[:to].is_a?(String) ? Chronic.parse(range[:to]) : range[:to] if range[:to]
        to_time ||= Time.now
        if from_time
          conditions << "from=#{from_time.getlocal('+00:00').iso8601}"
          conditions << "to=#{to_time.getlocal('+00:00').iso8601}"
        end
      end

      conditions << "summarize=true" if summarize

      conditions.join('&')
    end

    def validate_resource_options(options = {})
      raise ArgumentError.new("Need to define either an application or server id") unless options[:application] || options[:server]
      raise ArgumentError.new("Need to define either an application or server id, but not both") if options[:application] && options[:server]
    end

    def validate_metric_options(options={})
      validate_resource_options(options)
      raise ArgumentError.new("Metrics must be set") unless options[:metrics]
      raise ArgumentError.new("Metrics must be an hash") unless options[:metrics].is_a?(Hash)
      raise ArgumentError.new("Metric keys must be string") unless options[:metrics].keys.all?{|k| k.is_a?(String)}
      raise ArgumentError.new("Metric values must be arrays") unless options[:metrics].values.all?{|k| k.is_a?(Array)}
      raise ArgumentError.new("Metric values must be an array of strings") unless options[:metrics].values.all?{|k| k.all?{|v| v.is_a?(String)} }

      if options[:range] && options[:range]!={}
        raise ArgumentError.new("Range must only contain a :to and :from time") unless options[:range].keys.all?{|k| k==:to || k==:from }
        raise ArgumentError.new("Range must contain a :from time") unless options[:range].keys.include?(:from)
      end
    end

    def get(resource, resource_id, path, query=nil)
      uri = gen_uri(resource,resource_id,path,query)

      begin
        response = RestClient.get(uri,'X-Api-Key'=>@config.api_key)
      rescue => ex
        message = ex.response ? JSON.parse(ex.response).values.first['title'] : ex.message
        raise RequestFailed, message
      end

      begin
        content = JSON.parse(response)
      rescue => ex
        raise RequestFailed, ex.message
      end

      content
    end

    def gen_uri(resource,resource_id,path,query)
      uri       = URI.parse('https://api.newrelic.com/')
      uri.path  = "/v2/#{resource}/#{resource_id}/#{path}.json"
      uri.query = query if query && query != ""
      uri.to_s
    end
  end
end