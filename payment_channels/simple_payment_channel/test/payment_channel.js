const SinglePaymentChannel = artifacts.require("./SinglePaymentChannel.sol")

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

  // Send in the address we want to use, the contract address we are invoking, the value and nonce
  // as hex strings only using web3.toHex()
  function createSig(account, contractAddress, value, nonce) {
    // Change the value to hex. here it is a big number
    let proof = web3.sha3(contractAddress.slice(2) + value.slice(2).padStart(64, '0') + nonce.slice(2).padStart(64, '0'), { encoding: 'hex' }); 
    // We want to remove the 0x at the beginning   
    let sig = web3.eth.sign(account, proof).slice(2);  
    let signature = {      
        r: '0x' + sig.slice(0,64),      
        s: '0x' + sig.slice(64,128),    
        v: web3.toDecimal(sig.slice(128,130)) + 27
    };    
    return {
        signature,
        proof
    }
}

contract('PaymentChannel', function(accounts) {

  const alice = accounts[0];
  const bob = accounts[1];

  it("should deploy the contract and open a channel", async() => {
    let c = await SinglePaymentChannel.new({from: alice});
    await c.OpenChannel(bob, {from: alice, value: web3.toWei("1", "ether")})
    assert((await c.startDate.call()) > 0, "Not superior to 0")
    assert.equal((await c.amountDeposited.call()), web3.toWei("1", "ether"))
    // let's ensure that we can create a signature and validate with our smart contract:
    let sig = createSig(alice, c.address, web3.toHex("100000000000000000"), web3.toHex(1))
    let verify = await c.VerifyValidityOfMessage.call(sig.proof, sig.signature.v, sig.signature.r, sig.signature.s, web3.toHex("100000000000000000"), web3.toHex(1), {from: alice})
    assert(verify, "Verification failed");
  })


  it("Should exchange signatures once and close the channel, then finalize it", async() => {
    let c = await SinglePaymentChannel.new({from: alice});
    await c.OpenChannel(bob, {from: alice, value: web3.toWei("1", "ether")})
    // Let's send 0.1 ether to bob, that way, alice will receive 0.9 ETH and bob 0.1 ETH
    let aliceSig = createSig(alice, c.address, web3.toHex("100000000000000000"), web3.toHex(1))
    // Verify our signature works
    let verifyAlice = await c.VerifyValidityOfMessage.call(aliceSig.proof, aliceSig.signature.v, aliceSig.signature.r, aliceSig.signature.s, web3.toHex("100000000000000000"), web3.toHex(1), {from: alice})
    assert(verifyAlice, "Verification failed for alice");

    // Now bob closes the channel

    let isClosed = await c.CloseChannel(aliceSig.proof, aliceSig.signature.v, aliceSig.signature.r, aliceSig.signature.s, web3.toHex("100000000000000000"), web3.toHex(1), {from: bob})
    assert(isClosed, "Did not close properly")

    let lastPayment = await c.lastPaymentProof.call()

    assert.equal(lastPayment[0].toString(), 1, lastPayment[1].toString(), "100000000000000000" )
    
    // Here we add a time jump of 16 minutes
    await timeJump(16*60)

    // let's look at bob's balance before and after finalizing:
    let bobBalanceBefore = web3.eth.getBalance(bob)
    let finalize = await c.FinalizeChannel({from: alice})
    let bobBalanceAfter = web3.eth.getBalance(bob)
    assert(finalize, "Did not finalize properly")
    assert(bobBalanceAfter.minus(bobBalanceBefore).toString() === "100000000000000000", "Bob's balance has not increased by 0.1 eth but by")

  })


  it("Should exchange signatures once and close the channel, then challenge it and finalize it", async() => {
    let c = await SinglePaymentChannel.new({from: alice});
    await c.OpenChannel(bob, {from: alice, value: web3.toWei("1", "ether")})
   
///////////////////////////////////// OLD SIGNATURE /////////////////////////////////////
    // Let's send 0.1 ether to bob, that way, alice will receive 0.9 ETH and bob 0.1 ETH
    let oldAliceSig = createSig(alice, c.address, web3.toHex("100000000000000000"), web3.toHex(1))
    // Verify our signature works
    let verifyAlice = await c.VerifyValidityOfMessage.call(oldAliceSig.proof, oldAliceSig.signature.v, oldAliceSig.signature.r, oldAliceSig.signature.s, web3.toHex("100000000000000000"), web3.toHex(1), {from: alice})
    assert(verifyAlice, "Verification failed for alice");

    ///////////////////////////////////// New SIGNATURE /////////////////////////////////////
    // Let's send 0.1 ether to bob, that way, alice will receive 0.8 ETH and bob 0.2 ETH notice the different nonce!
    let newAliceSig = createSig(alice, c.address, web3.toHex("200000000000000000"), web3.toHex(2))
    // Verify our signature works
    verifyAlice = await c.VerifyValidityOfMessage.call(newAliceSig.proof, newAliceSig.signature.v, newAliceSig.signature.r, newAliceSig.signature.s, web3.toHex("200000000000000000"), web3.toHex(2), {from: alice})
    assert(verifyAlice, "Verification failed for alice");

    // Now bob closes the channel with an old message
    let isClosed = await c.CloseChannel(oldAliceSig.proof, oldAliceSig.signature.v, oldAliceSig.signature.r, oldAliceSig.signature.s, web3.toHex("100000000000000000"), web3.toHex(1), {from: bob})
    assert(isClosed, "Did not close properly")

    let lastPayment = await c.lastPaymentProof.call()
    assert.equal(lastPayment[0].toString(), 1, lastPayment[1].toString(), "100000000000000000" )
    
    // Alice now challenges bob's assertion
    let challenge = await c.Challenge(newAliceSig.proof, newAliceSig.signature.v, newAliceSig.signature.r, newAliceSig.signature.s, web3.toHex("200000000000000000"), web3.toHex(2), {from: alice})
    assert(challenge, "Challenge failed")
    // Here we add a time jump of 16 minutes
    await timeJump(16*60)

    // let's look at bob's balance before and after finalizing:
    let bobBalanceBefore = web3.eth.getBalance(bob)
    let finalize = await c.FinalizeChannel({from: alice})
    let bobBalanceAfter = web3.eth.getBalance(bob)
    assert(finalize, "Did not finalize properly")
    assert(bobBalanceAfter.minus(bobBalanceBefore).toString() === "200000000000000000", "Bob's balance has not increased by 0.2 eth")

  })
});



