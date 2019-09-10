RSpec.describe Deribit::API do
  let(:key) { "BxxwbXRLmYid" }
  let(:secret) { "AAFKHJXE5GC6QI4IUI2AIOXQVH3YI3HO" }
  let!(:api) { Deribit::API.new(key, secret, test_server: true) }

  context "with valid params" do
    it "#ping" do
      VCR.use_cassette "request/ping" do
        expect(api.ping).to eq("pong")
      end
    end

    it "#get_account_summary" do
      VCR.use_cassette "request/get_account_summary" do
        expect(api.get_account_summary(currency: "BTC")).to include(:equity, :available_funds, :delta_total)
      end
    end

    it "#buy" do
      VCR.use_cassette "request/buy" do
        expect(api.buy(instrument_name: "BTC-PERPETUAL", amount: 10, price: 10000)).to include(order: include(:amount, :average_price), trades: a_kind_of(Array))
      end
    end
  end

  context "with invalid params" do
    it "#get_account_summary" do
      VCR.use_cassette "request/get_account_summary_error" do
        expect { api.get_account_summary }.to raise_error(Deribit::Error)
      end
    end
  end
end
