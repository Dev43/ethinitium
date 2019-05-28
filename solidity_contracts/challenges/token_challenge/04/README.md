# SimpleToken Solidity challenge

## 04 Crowdfund constructor and fallback function

In this exercise, we will add functionality to the crowdfund constructor

- Change the constructor so that one can set a maxSupply, an ownerWallet, mint a number of tokens and inititalize the startBlock variable when deployed. The startblock should be the current block where the contract is mined.

- Change the fallback function so that when a user sends Ether, the buyTokens function would be called with the right variables.
