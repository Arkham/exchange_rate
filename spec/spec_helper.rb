$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "exchange_rate"
require "date"
require "pry"

RSpec.configure do |config|
  config.before(:each) do
    ExchangeRate::Sources::ECB.feed_path = nil
    ExchangeRate::Sources::ECB.reset_cache
  end
end
