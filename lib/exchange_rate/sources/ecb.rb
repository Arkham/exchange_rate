require 'ox'

module ExchangeRate
  module Sources
    class ECB
      class FeedNotFound < StandardError; end

      class << self
        attr_accessor :feed_path

        def at(date, source_currency, target_currency)
          @cache ||= exchange_rate_map
          find_rate(@cache, date, source_currency.to_s, target_currency.to_s)
        end

        def find_rate(rate_map, date, source_currency, target_currency)
          map_for_date = rate_map[key_for_date(date)]

          raise ArgumentError.new("Exchange rates not found for date #{key_for_date(date)}") if map_for_date.nil?

          [source_currency, target_currency].each do |currency|
            raise ArgumentError.new("Currency #{currency} not found") unless map_for_date.keys.include?(currency)
          end

          inverse_rate = (1.0/map_for_date[source_currency])
          map_for_date[target_currency] * inverse_rate
        end

        def reset_cache
          @cache = nil
        end

      private

        def exchange_rate_map
          raise FeedNotFound.new(<<~EOM) if feed_path.nil? || !File.exists?(feed_path)
            No feed found for this source! You should set a path for your feed by setting:
            ExchangeRate::Sources::ECB.feed_path = <path of the ECB feed>
          EOM

          File.open(feed_path) do |f|
            xml = Ox.parse(f.read)

            return xml.locate("gesmes:Envelope/Cube/*").each_with_object(Hash.new) do |cube, result|
              result[cube.time] = cube.nodes.each_with_object({ 'EUR' => 1.0 }) do |node, hash|
                hash[node.currency] = node.rate.to_f
              end
            end
          end
        end

        def key_for_date(date)
          date.strftime("%Y-%m-%d")
        end
      end
    end
  end
end
