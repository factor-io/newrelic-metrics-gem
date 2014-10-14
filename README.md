New Relic Metrics
======================
This is a Ruby gem to easily get metrics for your application or servers from New Relic using the V2 API.


## Installation

Using `gem`:

    gem install newrelic-metrics


Using 'bundle install' in your Gemfile:

    gem 'newrelic-metrics', '~> 0.0.3'


## Authentication
The API Key is kind hard to find in New Relic console. Here is how you find it...

**Account Settings > Integrations > Data Sharing > API access > "API Key"**


### Usage Example

```ruby
require 'newrelic_metrics'

api_key = ENV['NEWRELIC_API_KEY']
app_id  = ENV['NEWRELIC_APP_ID']

# Initialize API
api = NewRelicMetrics.new(api_key, application: app_id)

# Use this notation instead if you want to get metrics for
# servers instead of applications:
# 
# api = NewRelicMetrics.new(api_key, server: server_id)

# Getting list of available metrics
available_metrics = api.names

raw_metrics = api.metrics 'Apdex'=>['score']

last_24_hours_metrics = api.metrics({'Apdex'=>['score']},{from:'24 hours ago'})

last_weeks_metrics = api.metrics({'Apdex'=>['score']},{from:'2 weeks ago',to:'1 week ago'})

summary_metrics = api.summary({'Apdex'=>['score']}, {from: 'yesterday', to: 'now'})
# This call is equivalent to
# 
# summary_metrics = api.metrics({'Apdex'=>['score']}, {from: 'yesterday', to: 'now', summary: true})

```
