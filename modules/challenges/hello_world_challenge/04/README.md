# Hello World Challenge

## 4) Restricting access

Create a brand new owner variable.

On contract instantiation, the owner variable should be you.

Create a modifier `onlyOwner` that ensures that only the owner is the one performing an action

Add the `onlyOwner` modifier to the transfer function, ensuring that you are the only one able to transfer the Ether out of the contract