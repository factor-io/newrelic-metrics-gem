New Relic Metrics
======================
This is a Ruby gem to easily get metrics for your application or servers from New Relic using the V2 API.


## Installation

Using `gem`:

    gem install newrelic-metrics


Using `bundle install` in your `Gemfile`:

    gem 'newrelic-metrics', '~> 0.0.3'


## Authentication
The API Key is kind hard to find in New Relic console. Here is how you find it...

**Account Settings > Integrations > Data Sharing > API access > API Key**


### Usage Example

```ruby
require 'newrelic-metrics'

api_key = ENV['NEWRELIC_API_KEY']
app_id  = ENV['NEWRELIC_APP_ID']

# Initialize API
api = NewRelicMetrics.new(api_key, application: app_id)

# Use this notation instead if you want to get metrics for
# servers instead of applications:
# api = NewRelicMetrics.new(api_key, server: server_id)

# Getting list of available metrics
available_metrics = api.names

raw_metrics = api.metrics 'Apdex'=>['score']

last_24_hours_metrics = api.metrics({'Apdex'=>['score']},{from:'24 hours ago'})

last_weeks_metrics = api.metrics({'Apdex'=>['score']},{from:'2 weeks ago',to:'1 week ago'})

summary_metrics = api.summarize({'Apdex'=>['score']}, {from: 'yesterday', to: 'now'})
# This call is equivalent to
# summary_metrics = api.metrics({'Apdex'=>['score']}, {from: 'yesterday', to: 'now', summarize: true})

```

## API Docs
### NewRelicMetrics.new
The first variable is the API Key, the second is a hash. The hash must contain exactly one symbolic key named `application` or `server` referencing exactly one string value. If you use the application it will get metrics for applications, and servers resptively.

### names
This method takes no input and will get you the list of available metrics and the corresponding possible values. 

### metrics
This takes one required input, a hash, and one optional additional set of settings.

The first hash must contain a set of string keys and an arraay of strings for the values. The keys should reference the [names of metrics](https://docs.newrelic.com/docs/apm/apis/application-examples-v2/getting-apdex-data-apps-or-browsers-api-v2#apdex-names) while the values reference the values you want to get for that metric. You can use the `names` method to get a list of available metrics and their possible values.

The second hash provides additional settings:
- **summary**: can be set to `true` to summarize the data instead of getting the full list.
- **from**: a string representing the start time for the range of metric values to get. This uses the [Chronic](https://github.com/mojombo/chronic) to parse the time, so you can use values like `yesterday` or `one month ago`.
- **to**: this is the second half of the range. It too uses Chronic to parse the date. If `from` is specified by `to` is not, it will assume `Time.now`.

### summarize
This is just a shortcut method for getting a summary of the data. It works just like `metrics`, but assumes that you specified the `summarize: true` optional setting.
