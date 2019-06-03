# Token Challenge

## 00 Setup Truffle

In an empty folder, run `truffle init`

Feel free to look at the different files that get created.

In `truffle-config.js`, make sure that under `solc` you are using the correct version `0.5.4`

In the `contracts` folder, create a new file named `HelloWorld.sol` and add in this code.

```javascript
pragma solidity ^0.5.4;

contract HelloWorld {

    uint value;
    function set(uint _value) public {
        value = _value;
    }

    function get() public view returns (uint) {
        return value;
    }
}
```

In the `migrations` folder, create a new file named `2_deploy_hello_world.js` and add in this code:

```javascript
const HelloWorld = artifacts.require("HelloWorld");

module.exports = function(deployer) {
  // Use deployer to state migration tasks.
  deployer.deploy(HelloWorld)
};

```

In a terminal at the root directory of the folder, write `truffle develop`, a REPL should appear

Write `deploy`. Inspect what is shown to you.