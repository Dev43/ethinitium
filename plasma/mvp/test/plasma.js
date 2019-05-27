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

// need a function to take all transaction and create a merkle tree with it
// need a functon to concatenate all signatures together (format them correctly)
// need a function to "advance" the blockchain as it goes -- extremely simple case

contract('plasmaMVP', function(accounts) {

  let owner = accounts[0];
  let alice = accounts[1];
  let bob = accounts[2];


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

  // it("should return the correct week old block", async () => {
  //   let plasma = await PlasmaMVP.new();
  //   await plasma.deposit({from: alice, value: "100000000000000000"});
  //   // Jump 7 days
  //   await timeJump(7*24*60*60 + 5);

  //   let lastBlockNumber = await plasma.lastWeekOldBlock.call()
  //   assert(lastBlockNumber.toNumber() == 0, "not the right block number " + lastBlockNumber.toNumber());
    
  //   await plasma.deposit({from: alice, value: "10"});
  //   await timeJump(1*24*60*60);
  //   await plasma.deposit({from: accounts[1], value: "10"});
  //   await timeJump(1*24*60*60);
  //   await plasma.deposit({from: accounts[2], value: "10"});
  //   await timeJump(1*24*60*60);
  //   await plasma.deposit({from: accounts[3], value: "10"});
  //   await timeJump(1*24*60*60);
  //   await plasma.deposit({from: accounts[4], value: "10"});
  //   await timeJump(7*24*60*60);
    
    
  //   lastBlockNumber = await plasma.lastWeekOldBlock.call()
  //   // Need to do at least 1 exit first
  //   console.log(lastBlockNumber.toNumber())
  //   assert(lastBlockNumber.toNumber() == 1, "not the right block");


  // });

  // [blknum1, txindex1, oindex1, sig1, # Input 1
  //   blknum2, txindex2, oindex2, sig2, # Input 2
  //   newowner1, denom1,                # Output 1
  //   newowner2, denom2,                # Output 2
  //   fee]

  function newTransaction( blockNum1, txIndex1, oIndex1, sig1, blockNum2, txIndex2, oIndex2, sig2, newOwner1, denom1, newOwner2, denom2, fee) {
    return {
      blockNum1,
      txIndex1,
      oIndex1,
      sig1,
      blockNum2,
      txIndex2,
      oIndex2,
      sig2,
      newOwner1,
      denom1,
      newOwner2,
      denom2,
      fee,
      isSpent1: false,
      isSpent2: false,
      conf1: "",
      conf2: "",
  }
}

  function formatTransaction(tx) {
    // No signatures are encoded here
    return rlp.encode([
      tx.blockNum1,
      tx.txIndex1,
      tx.oIndex1,
      tx.blockNum2,
      tx.txIndex2,
      tx.oIndex2, 
      tx.newOwner1,
      tx.denom1,
      tx.newOwner2,
      tx.denom2,
      tx.fee
    ])
  }

  const NULL_ADDRESS = "0x0000000000000000000000000000000000000000"

  it("should start an Exit", async() => {
    let plasma = await PlasmaMVP.new();
    let depositAmount = "100000000000000000"
    // Create a deposit, and get its block hash
    await plasma.deposit({from: alice, value: depositAmount});

    // get the plasma block hash
    plasmaBlock = await plasma.plasmaBlocks.call(0)
    
    // A deposit block has all input fields, and the fields for the second output, zeroed out. 
    //To make a transaction that spends only one UTXO, a user can zero out all fields for the second input.
    let depositBlockHash = plasmaBlock[0]
    let depositBlockNumber = 0
    let submitter = alice;

    // create the correct txn
    let depositTxn = newTransaction(0,0,0,"",0,0,0,"",submitter,depositAmount,NULL_ADDRESS,0, 0)
    // first let's create a small blockchain 
    blockchain = newBlockchain(web3);

    // add into the block with the deposit transaction into our blockchain // has to have the same blockHash
    // we rlp encode the deposiTransaction first
    blockchain.push(newBlock(blockchain[blockchain.length -1].hash, depositBlockHash, [formatTransaction(depositTxn)]))

    // Now our blockchain has the genesis block and a deposit.
    
    // Let's create a spending transaction on the child chain so we can start an exit after
    // this transaction goes from bob to alice
    // Alice's UTXO was at blockNumber 0, position 0. We are creating an output to Bob, at index 0, and an output for alice at output 1
    let unsignedSpendingTxn = newTransaction(depositBlockNumber, 0, 0, "", 0, 0, 0, "", bob, "10000000000000000", alice, "90000000000000000",0)
    // we need to add the signature of this into the trasaction first -- we hash the UNSIGNED transaction and then create signature for it.
    let hashToSign = formatTransaction(unsignedSpendingTxn)
    
    let aliceSig = web3.eth.sign(alice, hash).slice(2);  

    // now we have the transaction signed by alice, the rightful owner of the UTXO.
    // we won't bother validating it with the state for this test
    // let's merklize this transaction so we can get the block hash
    let fullMerkle = merkleize(web3, [formatTransaction(unsignedSpendingTxn)])
    let newRoot = fullMerkle[1]

    // add the block to the blockchain
    blockchain.push(newBlock(blockchain[blockchain.length -1].hash, newRoot, [formatTransaction(unsignedSpendingTxn)]))





    // add in 1 transaction (easy, txId = 0)
    
    console.log(fullMerkle[0])
    // RLP encode the transaction
    
    
    // create a merkle tree with this information
    
    // submit the block hash to the contract (from the owner)
    
    // One needs to create a transaction from the owner to the same owner (need at least 1 tx to exit)  on the child chain
    
    // submit the new block hash to the main chain
    
    // Get all the necessary signatures (confirm sig etc)
    
    // Start the exit procedure
  })



});


function newBlock(prevHash, hash, txns) {
  return {
    prevHash,
    hash,
    txns
  }
}
function newBlockchain(web3) {
  // genesis block
  return [newBlock("", web3.sha3(0), [])
}

/* Each Merkle root should be a root of a tree with depth-16 leaves, where each leaf is a transaction. A transaction is an RLP-encoded object of the form:

[blknum1, txindex1, oindex1, sig1, # Input 1
 blknum2, txindex2, oindex2, sig2, # Input 2
 newowner1, denom1,                # Output 1
 newowner2, denom2,                # Output 2
 fee] */
function merkleize(web3, txList) {

  // We have a tx list, we hash all 2-2 together to produce a tree of depth 16.

  // First hash the list
  let hashedTx = []

  for(var i = 0; i < txList.length; i++) {
    hashedTx.push(web3.sha3(txList[i]))
  }
  const NULL_HASH = web3.sha3("");
  console.log(NULL_HASH)
  // Now let's add a whole bunch of null hashes until we fill our tree (2**h)
  while (hashedTx.length < 2**16) {
    hashedTx.push(NULL_HASH);
  }
  
  // Now we have all the leaves, we need to hash them 2 by two to create the parents.
  for(var i = 0; i < hashedTx.length; i++) {
    // If not pair, take the earlier one and hash it
    if( i % 2 === 0) {
        let parent = web3.sha3(hashedTx[i-1], hashedTx[i])
        hashedTx.push(parent)
    }
    // else we continue on
  }
  // let's add a 0 at the end so it's simpler for us
  hashedTx.push(0)

  // let's reverse it so it's easier for us to work with (we can reason better on the K, 2K and 2K+1 parent/child relationship)
  let fullTree = hashedTx.reverse()
  
  console.log(fullTree[1])
  console.log(fullTree[fullTree.length - 2])
  return fullTree

}