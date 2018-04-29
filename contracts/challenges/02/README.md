# BikeShare Solidity challenge

## 02 Variables

In this exercise, we will add the different global variables necessary for this contract

Add these global variables to the contract along with the correct data type:

- Initial credit price (creditPrice), should be worth 1 finney
- Initial cost per kilometer (cpkm) should be equal to 5
- Initial credits received for donating a bike (donateCredits) should be equal to 500
- Initial credits given for repairing a bike (repairCredits) should be equal to 250
- Mapping to keep track of the bikes rented (bikeRented). Each user has an address, and each bike is identified by a number
- Mapping to keep track of user's credit balances. Each user has an address, and a total amount of credits
- A new "type" of name Bike (Bike). A bike has an owner, knows whether it is rented or not, and has a total amount of kilometers ridden
- An array of said bike (bikes)


*For simplicity purposes every number should be represented as a uint256*