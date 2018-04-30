# BikeShare Solidity challenge

## 01 Structure

In this exercise, we will create a contract that adheres to the ERC20 interface

- Create a SimpleToken contract that adheres to the ERC20 standard.

- Add a mint function that takes in an address, and amount and is only callable by the owner and all other functions inside the contract

- Add a maxSupply variables that has a default of 1000

- The contract should be ownable, and use Safemath as a library for all uint256