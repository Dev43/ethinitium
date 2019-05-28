# SimpleToken Solidity challenge

## 05 BuyTokens and getRate

In this exercise, we will implement the buyTokens and getRate function

Change the getRate function so that it returns a different rate depending on the current block number:

- Returns 8 if within blocks 0 and 500 form startBlock
- Returns 7 if within blocks 500 and 750 form startBlock
- Returns 6 if within blocks 750 and 1000 form startBlock
- Returns 5 if over 1000



Change the buyTokens function so that it:

- Adds tokens to the users balance. The calculation should be proporational to the amount of ether sent (ether sent * rate)
- It transfers the ether directly to the ownerWallet
- It emits a TokenPurchase event
- It ensures that we are within 2000 blocks from the startBlock