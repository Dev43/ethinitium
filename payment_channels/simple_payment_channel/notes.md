# Payment Channels

## What is a payment channel

Before talking about what a payment channel is, let's first understand why we need them in the first place:

### Rationale

1. Ethereum is slow. The current maximal transaction per second that ethereum can handle can be calculated:

8000000 (block gas limit) / 21000 = 380.95. With a block time of about 15 seconds, we get about 381/15 = 25.39 transactions per seconds. This is not counting on "function calls", contract creation etc, that bring down the maximal tps of about 15 transactions per second (I'm missing a reliable source on this).

2. Micropayments are expensive -- with a gas limit of 21000 and a gas price that varies, we can have our simple ether transaction cost cents to dollars (add calculation here)
   
3. Does every single transaction need to be on the blockchain? Aggregating transactions makes it so the blockchain's space requirements don't accelerate, all we need to know is the outcome of multiuple transactions, not necessarily all the transactions in between (get space requitrement for the blockchain, get storage size of a transaction).

### Definition

> A Micropayment Channel or Payment Channel is class of techniques designed to allow users to make multiple Bitcoin transactions without commiting all of the transactions to the Bitcoin block chain.[1] In a typical payment channel, only two transactions are added to the block chain but an unlimited or nearly unlimted number of payments can be made between the participants. (https://en.bitcoin.it/wiki/Payment_channels)

## How does a payment channel work?

**TALK ABOUT FIRST SOLUTION AS IT DOES NOT MAKE IT POSSIBLE TO TRANSFER MONEY TO A FROM AND WHY**

### Data needed


## Token Payment Channel

## Dangers

### SpankChain

### Availability

### Centralization?
