# BikeShare Solidity challenge

## 04 Function Accessors

In this exercise, we will add function accessors to all necessary functions and variables

Create an automatic getters for:
- The bike array
- bikeRented mapping
- credits mapping

Set following functions to be accessible by anyone, including functions inside the contract:

- Constructor
- getAvailable
- getCreditBalances
- fallback function

Set following functions to be accessible by anyone, excluding functions inside the contract:

- returnBike
- rideBike
- rentBike
- setCreditPrice
- setCPKM
- setDonateCredits
- setRepairCredits

Set following functions to be accessible only inside the contract and not child contracts:

- purchaseCredits

Set following variables to be accessible only inside the contract and also by child contracts:

- creditPrice
- cpkm
- donateCredits
- repairCredits

Set the following function as a function that does not change state, but reads form it:

- getCreditBalance
- getAvailable


Challenge:

If purchaseCredits is private, how can we go about purchasing credits by simply sending a value transaction to the contract (aka sending ETH only, no calldata)