[![Code Climate](https://codeclimate.com/github/factor-io/newrelic-metrics-gem/badges/gpa.svg)](https://codeclimate.com/github/factor-io/newrelic-metrics-gem)
[![Dependency Status](https://gemnasium.com/factor-io/newrelic-metrics-gem.svg)](https://gemnasium.com/factor-io/newrelic-metrics-gem)
[![Build Status](https://travis-ci.org/factor-io/newrelic-metrics-gem.svg)](https://travis-ci.org/factor-io/newrelic-metrics-gem)
[![Test Coverage](https://codeclimate.com/github/factor-io/newrelic-metrics-gem/badges/coverage.svg)](https://codeclimate.com/github/factor-io/newrelic-metrics-gem)

New Relic Metrics
======================
This is a Ruby gem to easily get metrics for your application or servers from New Relic using the V2 API.


## Installation

Using `gem`:

    gem install newrelic-metrics


Using `bundle install` in your `Gemfile`:

    gem 'newrelic-metrics', '~> 0.0.3'

# Pro account required
This client uses a New Relic API which is blocked only for Pro accounts. You can get a free trial account from New Relic, but thereafter this will require a paid account.

## Authentication
The API Key is kind hard to find in New Relic console. Here is how you find it...

**Account Settings > Integrations > Data Sharing > API access > API Key**


### Usage Example

```ruby
require 'newrelic-metrics'

api_key = ENV['NEWRELIC_API_KEY']
app_id  = ENV['NEWRELIC_APP_ID']

# Initialize API
NewRelicMetrics.configure do |c|
  c.api_key = api_key
end

api = NewRelicMetrics::Client.new

# Alternativley you can use an instance configuration
#
# config = NewRelicMetrics::Configuration.new
# config.api_key = api_key
# api = NewRelicMetrics::Client.new(config)

# Getting list of available metrics
available_metrics = api.names(application: app_id)

# Getting metrics
current_apdex         = api.metrics(application: app_id, metrics: {'Apdex'=>['score']})
last_24_hours_metrics = api.metrics(application: app_id, metrics: {'Apdex'=>['score']}, range: {from:'24 hours ago'})
last_weeks_metrics    = api.metrics(application: app_id, metrics: {'Apdex'=>['score']}, range: {from:'2 weeks ago',to:'1 week ago'})
summary_metrics       = api.metrics(application: app_id, metrics: {'Apdex'=>['score']}, range: {from: 'yesterday', to: 'now'}, summarize:true)

# Getting consistent metrics across multiple calls
from = Chronic.parse('5 minutes ago')
last_24_hours_apdex = api.metrics(application: app_id, metrics: {'Apdex'=>['score']}, range: {from: from})
last_24_hours_errors = api.metrics(application: app_id, metrics: {'Errors/all'=>['error_count']}, range: {from: from})
```

## API Docs
### NewRelicMetrics.new
The first variable is the API Key, the second is a hash. The hash must contain exactly one symbolic key named `application` or `server` referencing exactly one string value. If you use the application it will get metrics for applications, and servers resptively.

### names
This method must specify the `application` or `server` value, but not both. It will list all the available metrics for the particular app or server.

### metrics

- **application** or **server**: the application or server ID for which you want to get metrics. One, but not both, must be defined.
- **metrics**: This is a Hash string keys and an array of strings for the values. The keys should reference the [names of metrics](https://docs.newrelic.com/docs/apm/apis/application-examples-v2/getting-apdex-data-apps-or-browsers-api-v2#apdex-names) while the values reference the values you want to get for that metric. You can use the `names` method to get a list of available metrics and their possible values.
- **summary**: can be set to `true` to summarize the data instead of getting the full list.
- **range**: a Hash with a `to` and `from` keys.
  - **from**: a string or a Time representing the start time for the range of metric values to get. This uses the [Chronic](https://github.com/mojombo/chronic) to parse the time, so you can use values like `yesterday` or `one month ago`.
  - **to**: this is the second half of the range. It too uses Chronic to parse the date. If `from` is specified by `to` is not, it will assume `Time.now`.

