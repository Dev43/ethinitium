# SimpleToken Solidity challenge

## 01 Structure

In this exercise, we will create a contract that adheres to the ERC20 interface

- Create a SimpleToken contract that adheres to the ERC20 standard.

- Make a brand new folder called `library` in the `contracts` folder. Copy 2 the two following libraries: [Ownable.sol](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/ownership/Ownable.sol) and [SafeMath.sol](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/math/SafeMath.sol) from OpenZeppelin and add them to the library folder.

- Add a mint function that takes in an address, and amount and is only callable by the owner and all other functions inside the contract. Do not implement the function body

- Add a maxSupply variables that has a default of 1000

- The contract should be Ownable, and use SafeMath as a library for all uint256