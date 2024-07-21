This repo is an ETH-portal Demo Dapp canister written in Motoko which gives users the ability to transfer ETH between Arbitrum & Base. It interfaces with the Supersolid 1.0 Proof-of-concept (https://github.com/EmperorOrokuSaki/supersolid/) which is a canister written in Rust.

### Disclaimer: DO NOT SEND ETH TO THIS DEMO
We wanted to use real Web3 assets on mainnet chains to prove the viability of Supersolid, but this is a rough demo and not meant for production use. The demo canisters are shut off when we aren't using them, so this isn't a dapp you can use. PLEASE DO NOT SEND ASSETS TO THIS DEMO!

# What is Supersolid?
Supersolid is a "meta-ledger" that makes it possible for users & smart contracts from any chain to natively transact with users & smart contracts on any other chain!

# How does it work?
## Components:
* *Virtual Balance "Meta-Ledger"* - A canister controls user accounts on multiple chains and all assets are held communally in these accounts. The canister keeps an internal ledger of which external users and smart contract accounts own "virtual balances" within the Supersolid accounts.
* *Relay Interface* - Native transactions sent to Supersolid accounts can contain commands. These commands can be relayed to smart contracts on any chain for simple cross-chain logic & data availability.

## Key concepts:
* *Virtual Balances* - A user or smart contract on any chain can have a “virtual balance” of assets within a Supersolid account on any other chain!
* *Memo Commands* - All Web3 transactions have the capacity to include read-only data (typically a “memo” field). Supersolid reads this data to automatically relay & execute cross-chain commands between users and smart contracts.

## Implementation:
1. Supersolid watches for transactions to its wallets across various integration chains.
2. Assets received by a transaction get added to the meta-ledger as “virtual balance” owned by the sender. The transaction may also contain commands in the memo field if the user was intending to do something with this balance right away.
3. An interpreter reads commands (if present) in the memo field of any transactions.
4. Any commands which need to be relayed are queried by integrated dapps or sent out as transactions as needed to a destination chain.

## Use cases
Supersolid makes it trivial for devs on any chain to create fully decentralized & secure cross-chain dapps which are hard to build today:
* Cross-chain pools for swaps & transfers.
* Cross-chain aggregators.
* Fractionalized ETH Mainnet transactions.
* Such as fractionalizing ownership of an Ethereum Liquity Trove into tokens on Solana.
* Crypto index funds (portfolio-backed tokens).
* Automated flashloan bots.
* Backed leverage tokens.
* Gasless virtual balance transfers & non-native wallets for smart contracts.

# What Supersolid makes possible
* Any user or smart contract from any chain can use Supersolid to do a transaction with any user or smart contract on any other chain. For example, using a native BTC transaction to open a Liquity Trove on Ethereum mainnet.
* Devs can deploy a smart contract that uses Supersolid on any chain they want.
* There’s potential for LP to be used in multiple ways at simultaneously, for incredible capital efficiency!
* Gaining liquidity for a new dapp would become as easy as integrating an API.

# Why Does This Matter?
## Problem it solves
It removes the cross-chain barriers from Web3.

## What we built during #OIS
The preliminary design of the Supersolid protocol and the completion of a functional proof-of-concept deployed to mainnet.

## Business model
Small transaction fees will be collected on every chain, denominated in whatever assets are being transferred. This revenue would backing and/or yield for a Supersolid native token.

## Demo
An ETH token portal between Base & Arbitrum (this repo).

# #OIS Judgement Criteria:
## Innovation Aspect
It’s a completely novel approach with no direct parallel in the industry, composed of several new concepts like “meta-ledger”, “virtual balances” & “memo field commands”.

## Product Potential
It disrupts many of the top projects within the Interoperability category (MC: ~$14.4b), such as THORChain (MC: ~$1.6b).

## Utility for the ICP Ecosystem
It’ll remove one of the biggest barriers the Web3 industry faces using a solution that perfectly highlights the unique capabilities of ICP, while also giving every canister direct access to universally composable multi-chain liquidity.

# Resources:
* Project Slide Deck: https://docs.google.com/presentation/d/1VXE3LvFynphkO_k2vxPYf4KOOHg6rs7I63BZxFqCCEs/edit?usp=sharing
* Supersolid 1.0 proof-of-concept Repo: https://github.com/EmperorOrokuSaki/supersolid/
* ETH-portal Demo Dapp Repo: https://github.com/InternetComputerOG/supersolid-eth-portal
* Project Presentation Video: (coming soon)