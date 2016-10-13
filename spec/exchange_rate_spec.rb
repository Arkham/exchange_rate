require "spec_helper"

describe ExchangeRate do
  it "has a version number" do
    expect(ExchangeRate::VERSION).not_to be nil
  end

  describe "::at" do
    let(:date) { Date.parse("12/10/2016") }

    before do
      ExchangeRate::Sources::ECB.feed_path = File.expand_path('../fixtures/sources/ecb.xml', __FILE__)
    end

    it "returns the exchange rate between two currencies at a certain date" do
      expect(described_class.at(date, "EUR", "USD")).to eq(1.102)
    end

    it "raises an error when any of the currency isn't known" do
      expect{ described_class.at(date, "EUR", "XOR") }.to raise_error(ArgumentError)
    end

    it "raises an error when no data is available for a certain date" do
      future_date = Date.parse("01/01/3000")
      expect{ described_class.at(future_date, "EUR", "USD") }.to raise_error(ArgumentError)
    end
  end
end
