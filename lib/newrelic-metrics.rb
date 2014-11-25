require 'restclient'
require 'json'
require 'uri'
require 'chronic'

module NewRelicMetrics
  class Configuration
    attr_accessor :api_key
    def initialize(api_key:nil,&block)
      @api_key=api_key
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

      raise ArgumentError, "No API Key is configured" unless @config && @config.api_key
    end

    def names
      get("metrics")
    end

    def summarize(application:nil, server:nil, metrics:, range:{})

      if range && range!={}
        throw ArgumentError, "Range must only contain a :to and :from time" if range.keys.length != 2
        throw ArgumentError, "Range must contain a from time" if range.include?(:from)
        throw ArgumentError, "Range must contain a to time" if range.include?(:to)
      end

      raise ArgumentError, "Need to define either an application or server id" unless application || server
      raise ArgumentError, "Need to define either an application or server id, but not both" if application && server

      @resource = application ? 'applications' : 'servers'
      @resource_id = application || server

      settings = {summarize:true}.merge(range)

      metrics(metrics,settings)
    end

    def metrics(metrics={},options={})
      query = ""
      conditions = []

      names = metrics.keys
      values = metrics.values.flatten

      names.each {|name| conditions << "names[]=#{URI.encode(name)}" }
      values.each {|val| conditions << "values[]=#{URI.encode(val)}" }

      if options[:from]
        from_time = Chronic.parse(options[:from], context: :past)
        to_time = Chronic.parse(options[:to]) if options[:to]
        to_time ||= Time.now
        if from_time
          conditions << "from=#{from_time.getlocal('+00:00').iso8601}"
          conditions << "to=#{to_time.getlocal('+00:00').iso8601}"
        end
      end

      conditions << "summarize=true" if options[:summarize]

      query = conditions.join('&')
      get("metrics/data",query)
    end

    private

    def get(path,query=nil)
      uri = URI.parse('https://api.newrelic.com/')
      uri.path = "/v2/#{@resource}/#{@resource_id}/#{path}.json"
      uri.query = query if query && query != ""

      begin
        response = RestClient.get(uri.to_s,'X-Api-Key'=>@config.api_key)
      rescue => ex
        if ex.response
          message = JSON.parse(ex.response).values.first['title']
          raise RequestFailed, message
        else
          raise RequestFailed, ex.message
        end
      end
    end
  end
end