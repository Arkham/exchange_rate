require "spec_helper"

describe ExchangeRate::Sources::ECB do
  let(:date) { Date.parse("12/10/2016") }

  describe "::at" do
    context "when feed_path hasn't been set" do
      it "raises an error" do
        expect{ described_class.at(date, "EUR", "EUR") }.to raise_error(ExchangeRate::Sources::ECB::FeedNotFound)
      end
    end

    context "when feed_path doesn't point to a file" do
      it "raises an error" do
        described_class.feed_path = "look_ma_no_hands.xml"
        expect{ described_class.at(date, "EUR", "EUR") }.to raise_error(ExchangeRate::Sources::ECB::FeedNotFound)
      end
    end

    context "given a valid feed" do
      before do
        described_class.feed_path = File.expand_path("../../fixtures/sources/ecb.xml", __FILE__)
      end

      it "returns the correct rate for between euro and another currency" do
        expect(described_class.at(date, "EUR", "USD")).to eq(1.102)
      end

      context "when no data is available for a certain date" do
        it "raises an error" do
          future_date = Date.parse("01/01/3000")
          expect{ described_class.at(future_date, "EUR", "XOR") }.to raise_error(ArgumentError)
        end
      end

      context "when any currency is unknown" do
        it "raises an error" do
          expect{ described_class.at(date, "EUR", "XOR") }.to raise_error(ArgumentError)
          expect{ described_class.at(date, "XOR", "EUR") }.to raise_error(ArgumentError)
        end
      end

      context "when getting multiple rates" do
        it "memoizes the data loading" do
          expect(described_class.at(date, "EUR", "USD")).to eq(1.102)
          expect(described_class).not_to receive(:exchange_rate_map)
          described_class.at(date, "EUR", "USD")
        end
      end
    end
  end

  describe "::find_rate" do
    let(:map) do
      {
        "2016-10-12" => {
          "EUR" => 1.0,
          "USD" => 2.0,
          "GBP" => 0.5
        }
      }
    end

    conversions = [
      ["EUR", "EUR", 1.0],
      ["EUR", "GBP", 0.5],
      ["EUR", "USD", 2.0],
      ["USD", "EUR", 0.5],
      ["GBP", "EUR", 2.0],
      ["GBP", "USD", 4.0],
      ["USD", "GBP", 0.25],
    ]

    conversions.each do |source, target, rate|
      it "finds the exchange rate using euro as a conversion tool, #{source} -> #{target} = #{rate}" do
        expect(described_class.find_rate(map, date, source, target)).to eq(rate)
      end
    end
  end
end
