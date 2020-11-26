require 'restclient'
require 'json'
require 'uri'
require 'chronic'
require 'link_header'

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
    BASE = 'https://api.newrelic.com/'

    def initialize(config=nil)
      @config = config || NewRelicMetrics.configuration

      raise ArgumentError.new("No API Key is configured") unless @config && @config.api_key
    end

    def names(options={}, &block)
      validate_resource_options(options)
      resource_id = options[:application] || options[:server]
      resource    = options[:application] ? 'applications' : 'servers'
      query       = "name=#{options[:name]}" if options[:name]
      
      get(resource, resource_id:resource_id, path:"metrics", query:query, root_node:"metrics", &block)
    end

    def applications(options={}, &block)
      resource = 'applications'
      query    = "filter[name]=#{options[:name]}" if options[:name]

      get(resource, query:query, root_node:"applications", &block)
    end

    def metrics(options={}, &block)
      validate_metric_options(options)
      resource_id = options[:application] || options[:server]
      resource    = options[:application] ? 'applications' : 'servers'
      query       = generate_metrics_query(options)

      get(resource, resource_id:resource_id, path:"metrics/data", query:query, root_node:"metric_data", &block)
    end

    private

    def generate_metrics_query(options={})
      range      = options[:range] || {}
      conditions = []

      options[:metrics].keys.each {|name| conditions << "names[]=#{URI.encode(name)}" }
      options[:metrics].values.flatten.each {|val| conditions << "values[]=#{URI.encode(val)}" }

      if range[:from]
        from_time = range[:from].is_a?(String) ? Chronic.parse(range[:from], context: :past) : range[:from]
        to_time = range[:to].is_a?(String) ? Chronic.parse(range[:to]) : range[:to] if range[:to]
        to_time ||= Time.now
        if from_time
          conditions << "from=#{from_time.getlocal('+00:00').iso8601}"
          conditions << "to=#{to_time.getlocal('+00:00').iso8601}"
        end
      end

      conditions << "summarize=true" if options[:summarize]

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

    def get(resource,options={})
      next_uri = gen_uri(resource,options)

      begin
        begin
          response = RestClient.get(next_uri,'X-Api-Key'=>@config.api_key)
          lh       = LinkHeader.parse(response.headers[:link]).to_a.find { |v| v.flatten.include?('next') }
          content  = JSON.parse(response)
          content  = content.fetch(options[:root_node]) if options[:root_node]
          if block_given?
            yield content
          else
            return content
          end
          next_uri = lh && lh.first
        end while next_uri
      rescue => ex
        message = ex.response ? JSON.parse(ex.response).values.first['title'] : ex.message
        raise RequestFailed, message
      end
    end

    def gen_uri(resource,options={})
      resource_id = options[:resource_id]
      path        = options[:path]
      query       = options[:query]

      uri       = URI.parse(BASE)
      uri.path  = "/v2/#{resource}"
      uri.path  += "/#{resource_id}" if resource_id
      uri.path  += "/#{path}" if path
      uri.path  += ".json"
      uri.query = query if query && query != ""
      uri.to_s
    end
  end
end
