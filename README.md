# Stellar Gateway

This Rails application is a gateway between crypto-assets and Stellar tokens. It is useful for Stellar anchors.

## Requirements

### Deposits only

- Running [Crypto Cold Store](https://github.com/bloom-solutions/crypto-cold-store) for cold storage

### Withdrawals only

- Running [Stellar Bridge](https://github.com/stellar/bridge-server/blob/master/readme_bridge.md) to detect payments to Stellar Gateway
- Access to a [BitGo](http://bitgo.com) wallet for hot storage

## Features
- [Deposit cryptocurrencies](#deposit)
- [Withdraw cryptocurrencies](#withdraw)

### Supported Cryptocurrencies

- [x] Bitcoin
- [ ] Ethereum
- [ ] Litecoin

### Deposit
See `spec/requests/deposit_spec.rb`

### Withdraw
See `spec/requests/withdraw_spec.rb`

## Setup

Ensure that the environment variables in `.env` are set.
