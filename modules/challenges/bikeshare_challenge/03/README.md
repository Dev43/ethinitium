# BikeShare Solidity challenge

## 03 Using the context

In this exercise, we will start implementing a few interesting functions using some of the context variables we saw earlier.

- In the constructor, initialize the bike array with 5 new bikes, each of the bikes owner is you. Initialize the struct with default values.
- Implement the purchaseCredit function. The amount of credits received should be proportional to the amount of ether sent. After the function runs, the user should have a balance of credits.
- Implement a getCreditBalance function. It should take in as input and address and simply read the credits mapping and return the credits balance of a user.
