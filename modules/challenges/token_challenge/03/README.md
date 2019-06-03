# SimpleToken Solidity challenge

## 03 Crowdfund initialization

In this exercise, we will add a crowdfund contract

- Create a SimpleCrowdfund file
- Add a constructor
- SimpleCrowdfund inherits from SimpleToken

Add the following functions to the crowdfund contact:

- buyTokens, takes in an address as input and returns a boolean
- getRate, takes in no argument, is constant and returns a uint256
- fallback function

Add two variables:

- ownerWallet, it is an address
- startBlock that keeps track of the start block for the crowdfund

Add one event:

- TokenPurchase that takes in an address and a value. The address should be searchable.

Don't forget to update your migration script