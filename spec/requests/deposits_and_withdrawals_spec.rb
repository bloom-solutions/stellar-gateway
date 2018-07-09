require 'rails_helper'

RSpec.describe "Deposits and withdrawals" do

  describe "depositing and withdrawing bitcoin" do
    let(:client) { Stellar::Client.default_testnet }
    let(:source) { Stellar::Account.from_seed(CONFIG[:source_seed]) }
    let(:issuer) { Stellar::Account.random }
    let(:gateway) { Stellar::Account.random }
    let(:stellar_recipient) { Stellar::Account.random }
    let(:btc_recipient) { "bitcoin-receiving-addr" }

    before do
      [issuer, gateway, recipient].each do |account|
        client.create_account(funder: source, account: account, balance: 2.0)
      end
    end

    it "allows depositing and withdrawal of BTC" do
      post("/api/v1/deposits", {
        coin: "btc",
        destination: stellar_recipient.address,
      })

      expect(response).to be_success
      parsed_response = JSON.parse(response.body)
      expect(parsed_response[:deposit_address]).to be_present

      # - Send 0.01 BTC on testnet to `destination`
      #
      # - Check cold store for new payments.
      #   Perhaps clean up message_bus-client so we can trigger
      #   calls and not have it thread in our tests.
      #   On prod, this can potentially be run
      #   in a worker instead of in each instance of the web server.
      #   See https://github.com/bloom-solutions/message_bus_client

      recipient_info = client.account_info(recipient)
      balances = recipient_info.balances
      expect(balances).to_not be_empty
      btc_asset_balance_info = balances.find do |b|
        b["asset_type"] == ENV.fetch("BTC_ASSET_CODE")
      end
      expect(btc_asset_balance_info["balance"].to_f).to eq 0.01

      # withdraw
      # NOTE: consider using federation
      post("/api/v1/withdrawals", {
        coin: "btc",
        destination: btc_recipient,
      })

      expect(response).to be_success
      parsed_response = JSON.parse(response.body)
      expect(parsed_response[:deposit_address]).to be_present
      expect(parsed_response[:memo]).to be_present
      expect(parsed_response[:fee]).to be_a Number # how much will be deducted

      client.send_payment(
        from: stellar_recipient,
        to: gateway,
        amount: 0.005,
        memo: parsed_response[:memo],
      )

      # Check the btc address
      # It should have (0.005 - parsed_response[:fee]) BTC
    end

  end

end
