# SimpleToken Solidity challenge

## 06 Testing

In this exercise, we will implement a few tests for our contract. Automated testing is *extremely important*.

In the test directory, create a new file called `token.js`

Inside it, add the following code 

```javascript
const SimpleCrowdfundArtifact = artifacts.require("./SimpleCrowdfund");

contract('SimpleCrowdfund', function (accounts) {
  let simpleCrowdfund;

  it("should assert true", async () => {
    simpleCrowdfund = await SimpleCrowdfundArtifact.deployed();
    assert.isTrue(simpleCrowdfund.address !== "", "no address for the contract");
  });

});
```

The simpleCrowdfund variable is an object representing our smart contract. It has all of the public/external functions of the smart contract as methods.

So for example, to call our getRate function, all we need to do is call it from our object:

`let rate = await simpleCrowdfund.getRate()`

When calling such a function, a promise is returned. Be sure to use either the `.then()` or the `async/await` notation to get the result of the promise.

Create 2 new tests, one to verify that the current rate of the contract is 8 and the other that buys tokens for `accounts[1]` from `accounts[0]` with a value of 10000 Wei

