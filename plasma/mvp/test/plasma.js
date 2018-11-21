const PlasmaMVP = artifacts.require("./PlasmaMVP.sol")
let rlp = require("rlp");


async function timeJump(timeToInc) {
  return new Promise((resolve, reject) => {
      web3
          .currentProvider
          .sendAsync({
              jsonrpc: '2.0',
              method: 'evm_increaseTime',
              params: [(timeToInc)] // timeToInc is the time in seconds to increase
          }, function (err, result) {
              if (err) {
                  reject(err);
              }
              resolve(result);
          });
  });
}


contract('plasmaMVP', function(accounts) {

  let owner = accounts[0];
  let alice = accounts[1];

  it("should ensure it is deployed true", async () => {
    let plasma = await PlasmaMVP.deployed();
    assert(plasma !== undefined, "Not deployed");
  });

  it("should deploy a new plasma and allow a block to be submitted", async () => {
    let plasma = await PlasmaMVP.new();
    let hash = web3.sha3("hello")
    await plasma.submitBlock(hash, {from: owner})

    let plasmaBlocks = await plasma.plasmaBlocks.call(0);
    assert.equal(plasmaBlocks[0], hash, "hash should match")
    assert(plasmaBlocks[1].toNumber() !== 0, "timestamp should exist")
  });

  it("should deploy a new plasma and allow a deposit", async () => {
    let plasma = await PlasmaMVP.new();
    await plasma.deposit({from: alice, value: "100000000000000000"});
    let encodedAmount = (web3.toHex("100000000000000000")).slice(2).padStart(64, '0')
    let hash = web3.sha3(alice.slice(2) + encodedAmount, { encoding: 'hex' })
    let plasmaBlocks = await plasma.plasmaBlocks.call(0);
    assert.equal(plasmaBlocks[0], hash, "hash should match")
    assert(plasmaBlocks[1].toNumber() !== 0, "timestamp should exist")
  });

  it("should return the correct week old block", async () => {
    let plasma = await PlasmaMVP.new();
    await plasma.deposit({from: alice, value: "100000000000000000"});
    // Jump 7 days
    await timeJump(7*24*60*60 + 5);

    let lastBlockNumber = await plasma.lastWeekOldBlock.call()
    assert(lastBlockNumber.toNumber() == 0, "not the right block");
    
    await plasma.deposit({from: alice, value: "10"});
    await timeJump(1*24*60*60);
    await plasma.deposit({from: accounts[1], value: "10"});
    await timeJump(1*24*60*60);
    await plasma.deposit({from: accounts[2], value: "10"});
    await timeJump(1*24*60*60);
    await plasma.deposit({from: accounts[3], value: "10"});
    await timeJump(1*24*60*60);
    await plasma.deposit({from: accounts[4], value: "10"});
    await timeJump(7*24*60*60);
    
    
    lastBlockNumber = await plasma.lastWeekOldBlock.call()
    assert(lastBlockNumber.toNumber() == 1, "not the right block");


  });




});
