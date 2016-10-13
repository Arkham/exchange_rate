require "exchange_rate/version"
require "exchange_rate/sources/ecb"

module ExchangeRate
  def self.at(date, source_currency, target_currency)
    Sources::ECB.at(date, source_currency, target_currency)
  end

  def self.currencies
    Sources::ECB.currencies
  end
end
