const PlasmaMVP = artifacts.require("./PlasmaMVP.sol")
let rlp = require("rlp");

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




});
