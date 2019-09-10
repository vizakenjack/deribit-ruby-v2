RSpec.describe Deribit::API do
  let(:ws) { Deribit::WS.new(key, secret, test_server: true).tap { |ws| ws.connect } }

  after do
    sleep 1
  end

  context "not authed" do
    let(:key) { nil }
    let(:secret) { nil }

    it "#ping" do
      ws.ping
      expect(ws.handler).to receive(:process).at_least(:once).with(anything, a_hash_including(method: "ping"))
    end

    it "#test" do
      ws.test
      expect(ws.handler).to receive(:process).at_least(:once).with(anything, a_hash_including(method: "test"))
    end

    it "#subscribe" do
      ws.subscribe channels: ["deribit_price_index.btc_usd"]
      expect(ws.handler).to receive(:subscription).at_least(:once).with(a_hash_including(params: include(:channel, :data)))
    end

    it "#unsubscribe" do
      ws.handler.subscriptions = ["deribit_price_index.btc_usd"]
      ws.unsubscribe channels: ["deribit_price_index.btc_usd"]
      sleep 1
      expect(ws.handler.subscriptions).to be_empty
    end

    it "#get_account_summary" do
      ws.get_account_summary currency: "BTC"
      expect(ws.handler).to receive(:process).with(a_hash_including(error: { :code => 13009, :message => "unauthorized" }), any_args)
    end
  end

  context "with auth" do
    let(:key) { "BxxwbXRLmYid" }
    let(:secret) { "AAFKHJXE5GC6QI4IUI2AIOXQVH3YI3HO" }

    before do
      allow(ws.handler).to receive(:process).with(anything, "auth")
    end

    it "#get_account_summary" do
      ws.get_account_summary currency: "BTC"
      expect(ws.handler).to receive(:process).with(a_hash_including(result: include(:balance)), a_hash_including(method: "get_account_summary"))
    end
  end
end
