# BikeShare Solidity challenge

## 06 Inheritance

In this exercise, we will inherit from another contract and use it's functions

Inherit from the Ownable contract in the library folder

Implement and add the onlyOwner modifier for these functions:

- setCreditPrice
- setCPKM
- setDonateCredits
- setRepairCredits

Create a new function called sendToOwner that can only be called by the owner and sends *all* of the Ether locked in the contract to him. The function should return a boolean.