# Exchange Rate

This gem provides exchange rates. Right now it supports the [ECB feed](http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml).
You can use it like this:

```ruby
require 'date'
require 'exchange_rate'

ExchangeRate::Sources::ECB.feed_path = <path of the feed>

ExchangeRate.at(Date.today, "GBP", "USD")
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'exchange_rate'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install exchange_rate

## Caveats

For performance reasons, we cache the loading and parsing of the ECB feed. You
can reset the cache by running:

```ruby
ExchangeRate::Sources::ECB.reset_cache
```

## Running tests

```bundle install && rspec spec```
