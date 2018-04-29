# BikeShare Solidity challenge

## 05 Error handling and modifiers

In this exercise, we will add modifiers and error handlers to protect our functions:

Implement 3 functions:

- rentBike: takes as argument a bikeNumber and allows the message sender to rent a bike
- rideBike: takes in the amount of kilometers the user is riding the bike, reduces the amount of credits the user has accordingly
- returnBike: let's the user return the bike

Create 4 modifiers with these functionalities:

- A modifier called onlyBikeOwner, that takes in a bikeNumber as argument and reverts if the bike owner of the specific bike is not the sender of the message
- A modifier called canRent, that takes in a bikeNumber as argument ensures that the bike is not rented, and that the owner is currently not renting another bike
- A modifier called hasRental, that takes in no arguments and ensures that the message sender owns the rental
- A modifier called hasEnoughCredits, that takes in the amount of kilometers the owner wants to bike, and ensure that he has enough credits when calculating the kilometers times the cost per kilometers

Refactor the functions and add these modifiers to the correct functions
