# Payment Channels

## What is a payment channel?

### Definition

> A Micropayment Channel or Payment Channel is class of techniques designed to allow users to make multiple Bitcoin transactions without commiting all of the transactions to the Bitcoin block chain. <sup>[1](https://en.bitcoin.it/wiki/Payment_channels)</sup> In a typical payment channel, only two transactions are added to the block chain but an unlimited or nearly unlimited number of payments can be made between the participants.

Using digital signatures a a bit of logic, we will be able to create a full fledged payment channel between two users.

### Rationale

Why are payment channels even necessary? We all know that we can transfer ether and tokens by sending the transactions directly to the blockchain and this transaction will probabilisticly be final after a certain amount of blocks.

1. *Ethereum is slow*. The current maximal transaction per second that Ethereum can handle can easily be calculated: assuming a block gas limit of 8000000 and a simple ether transaction costing 21000 gas units, we can calculate how many transactions fit in a block `8000000 / 21000 =~ 380`. With a block time of around 15 seconds, we get about `381/15 =~ 25` transactions per seconds. This is not counting on "function calls", contract creation etc, that bring down the average tps of about 15 transactions per second.
2. *Micropayments are expensive*. with a gas limit of 21000 and a gas price that varies, we can have our simple ether transaction cost fraction of a cent to dollars multiple dollars. This is also not taking into account token transfers which usually cost upwards of 50000 gas units.
3. *Storage*. Does every single transaction need to be on the blockchain? Including only transactions that matter using payment channels helps alleviate the blockchain's storage requirements as more people join the network
4. *Bandwidth*. Every transaction sent to an Ethereum node gets dispersed to other nodes using the gossip protocol. Now this is sustainable if you don't have that many transactions flowing in the network. This leads to pending transaction pool bloat, and requires miners to have a better bandwidth allocation. So aggregating multiple transactions to and from the same parties would be ideal.
5. *Privacy*. With payment channels as we will see, all we need to do is exchange a signed message between two parties and no-one else!. This means we can use any protocol to exchange this information (even paper!). We can encrypt the contents of our message, use secure channels no no one can snoop around and see what we are transferring. Only the opening and the closing state will be publicly viewable, nothing in between.

## How does a payment channel work?

In its essence, a payment channel is an exchange of valid signed transactions that send ether from one person to another. This valid transaction can be sent to blockchain from either party at any time. We will be using two fictional characters all throughout our examples, our beloved Alice and Bob.

### Simplest "payment channel" (no smart contract)

This example will be very brief but is simply there to get us accustomed to the concepts. Alice could enter into an agreement with Bob that she will be sending him valid signed Ethereum transactions and tells Bob not to spend it right away. As bob does more work, Alice sends him a new signed transaction with a higher ether value and the same nonce. Bob, at any time, can decide to send this transaction to the network to get the full payout. Of course, this solution is very fragile as Alice can simply send Bob a valid signed message and then drain her account of ether. Somehow we need to lock Alice's funds so Bob can be sure that he will get paid.

### Unidirectional payment channel

Here by unidirectional, we mean the transfer of ether goes only 1 way (here from Alice to Bob) and the value can only be increasing.

To create such a channel, we can create a smart contract that locks Alice's funds for a specific amount of time. There is a great [article](https://medium.com/@matthewdif/Ethereum-payment-channel-in-50-lines-of-code-a94fad2704bc) (and extremely simple example) of such a smart contract written by Matthew Di Ferrante [@matthewdif](https://medium.com/@matthewdif).

Simply put, to achieve such a channel, Alice locks the total amount of ether she is willing to pay Bob. At that point, as she is sending payments to Bob, every time she crafts a new message saying that she will be paying bob a specific value. With this message, Bob can verify that this message is valid and would lead to him getting paid the actual value. This is important to understand: Bob can cash out at any time. He hold Alice's signature and can also craft such a message with his own signature. Although it would be more beneficial for Bob to keep the channel open, as he could get more money if Alice sends him more messages.

Now this leads to a problem. Alice has her money locked in this contract. Bob has both signatures needed to close the channel and can decide to keep the channel open as long as possible. Another possibility is that bob is not available anymore.

That's why there is a general timeout to the channel. Assuming the channel times out and was never closed, Alice would get the totality of what she inputted, so bob needs to make sure to close the channel beforehand.

### Unidirectional payment channel with a challenge period

In another great and more hand on [article](https://blog.gridplus.io/a-simple-Ethereum-payment-channel-implementation-2d320d1fad93) about payment channels written by Alex Miller [@asmiller1989](https://blog.gridplus.io/@asmiller1989), we see a slightly more complex logic.

In his V2 version of the payment channel, he introduces multiple improvements:

- Nonces. For every new message add a counter (nonce) to the signed message. The message with the higher nonce is the latest message.
- Challenge period.
  
Those two innovations are great, but in his solution, only the receiver (here Bob) can close the channel and either Alice or Bob can challenge the channel granted tha the nonce is greater.

This poses 2 problems

1) What if bob never closes the channel
2) Alice can create as many messages as she wants with a different nonce. So that means that Alice will always win out (or at least have the chance to do so)/

## Bidirectional payment channels

Bidirectional payment channels are very similar to unidirectional payment channels but you need both participants to input a value in ether. Than the message becomes how you seperate the ether between the two. For example, let us assume Alice and Bob have contributed 1 ether each in the payment channel, totalling 2 ether. When Alice wants to pay Bob 0.5 ether, Alice sends a message that divides the 2 ether in between them, i.e. 0.5 ether to alice and 1.5 to bob.

This channel needs to be able to be closed by both parties, but again it should have a challenge period and nonce relating to what is the actual latest message.


### Example 

#### A semi-bidirectional payment channel

Why semi-bidirectional? I've simplified this example so only Alice needs to deposit money into the channel, but the amount sent to bob does not need to monotonically increase. You can think of it as Alice is a customer and Bob is a merchant. Alice will be paying bob most of the time, but Bob can actually reimburse alice on some expenses. So we have a two way flow, even though at first Alice is the one with all of the money.

Alice wants to pay bob for a particular service. This service involves multiple micropayments, which would make it unfeasible to use Ethereum to make those transactions. Bob does not trust alice to settle the whole bill at the end and would like his payments to be given incrementally (or at least, an assurance of it).

So Alice deploys a smart contract where she declares the counterparty as Bob and she deposits a total maximal sum that the contract holds. For simplicity, we won't allow Alice or Bob to add more funds into the contract after the channel is open.

```javascript
  // Sends a proof (bytes32 hash) and a nonce with the value that it needs to be
  function OpenChannel(address _bob) external payable {
    // Ensure we are sending at least some ether
    require(msg.value > 0, "you must send ether to open a channel");
    // Ensure alice is the only one able to open the channel
    require(alice == msg.sender, "only alice can open a channel");
    // Ensure we are not sending a garbage address
    require(_bob != address(0), "bob's address cannot be the 0 address");
    // Ensure this is a single use payment channel
    require(startDate == 0, "you cannot reopen a payment channel");
    // add bob's address
    bob = _bob;
    // startdate is now
    startDate = now;
    // we record the amount amountDeposited
    amountDeposited = msg.value;
    // Initiate the default payment proof
    lastPaymentProof = Payment({nonce: 0, value: msg.value});
  }
```

We have now opened a payment channel between Bob and Alice. Now for Alice to start paying Bob, all she has to do is to sign a massage of intent saying that she will be sending Bob a certain amount of ether. 

In our solution, the message that needs to be signed includes three pieces of information:

- the `address` of the payment channel contract
- the `value` that Alice is willing to send to Bob
- the `nonce` of the message (simple message counter)


Now to create a digital signature using these three values and either Alice's or Bob's private key, we need to bring this message down to 32 bytes. How best to do this but to use a cryptographic hash function. Solidity let's us use keccack256. We take all three values in order, concatenate them and take the keccak256 of the resulting string. In solidity `abi.encodePacked(address(this), value, nonce)`. This gives us a 32 byte output which we will call *proof*, with which we can sign using a private key.

Here it is shown using javascript. One can see this [here](https://github.com/Dev43/ethinitium/blob/master/payment_channels/simple_payment_channel/test/payment_channel.js)

```javascript
  function createSig(account, contractAddress, value, nonce) {
    // Proof is the contract address, the value (padded to uin256) and the nonce(padded to uint256)
    // The .slice(2) remove the "0x" at the beginning of all the strings
    let proof = web3.sha3(contractAddress.slice(2) + value.slice(2).padStart(64, '0') + nonce.slice(2).padStart(64, '0'), { encoding: 'hex' }); 
    // Here we sign the proof with the associated account
    let sig = web3.eth.sign(account, proof).slice(2);  
    // Extract the information from the signature
    let signature = {
        r: '0x' + sig.slice(0,64),
        s: '0x' + sig.slice(64,128),
        v: web3.toDecimal(sig.slice(128,130)) + 27
    };
    // We return the signature object and the proof
    return {
        signature,
        proof
    }
}
```

Alice now signs such a message with her private key and sends it to Bob. Again, She sends the signature and the three other values, address, value and nonce to bob. Bob can now verify this message concatenating the three arguments hashing them together and now verifying that the signature came from Alice signing the message. Now bob does the same, signs the message and sends it to Alice. Now both of them have the same message but signed by two different parties. At this point one can assume that the payment has officially ocurred.

At anytime now, either of them is able to "close" the channel, meaning cashing out. All that either party needs to do is to call the `Close` function on the smart contract with both valid signatures and the respective values (nonce and value). From there, the smart contract will verify both signatures and start the challenge period. 

```javascript
  // Anyone can close this channel but needs to give in both proofs
  function CloseChannel(
    bytes32 _proof,
    uint8[2] _v,
    bytes32[2] _r,
    bytes32 [2]_s,
    uint256 _value,
    uint256 _nonce
  ) external returns(bool) {
    // Ensure one can only close the channel once
    require(startChallengePeriod == 0, "cannot close the channel multiple times");
    require(VerifyValidityOfMessage(_proof, _v[0], _r[0], _s[0], _value, _nonce, alice), "alice's proof is not valid");
    require(VerifyValidityOfMessage(_proof, _v[1], _r[1], _s[1], _value, _nonce, bob), "bob's proof is not valid");
    // Update the last payment information
    lastPaymentProof = Payment({nonce: _nonce, value: _value});
    // Start the challenge period
    startChallengePeriod = now;
    return true;
  }

```

 We've set a 15 minute "challenge period" where the opponent (or actually anyone) with two valid signatures will be able to change the outcome of the payment.  As multiple messages get sent between bob and alice, it'd be trivial for any of them to use the message that makes them the most money. This where the nonce comes in. By ensuring that the nonce goes up every single time, and enforcing the fact the the highest nonce wins on the smart contract, you cannot get anyone to cheat and send in an old signature that makes them the most money.

 Also, we cannot let only one of the parties be able to sign the message. Here we made it so you have to provide the other party's signature with a higher nonce for it to be valid. If the signature is valid and the nonce is greater than the last signature stored on the contract, then we update the latestProof value on the contract

 ```javascript
   // For a successful challenge, we need a signed message from the **other** party with a higher nonce than the last one
  // Anyone can challenge (not only bob or alice)
  function Challenge(
    bytes32 _proof,
    uint8 _v,
    bytes32 _r,
    bytes32 _s,
    uint256 _value,
    uint256 _nonce
    ) external  returns(bool) {
      // Ensure we are in the challenge period
      require(startChallengePeriod > 0, "channel is not in closed state");
      // Ensure we are in the challenge period
      require(startChallengePeriod + challengePeriodLength > now, "challenge period has not ended");
      // If the sender is alice, then she has to show a message from bob with a valid nonce
      if(msg.sender == alice) {
        require(VerifyValidityOfMessage(_proof, _v, _r, _s, _value, _nonce, bob), "proof that bob signed this message is not valid");
      } else {
        // Else bob has to show a valid message from Alice with a valid nonce
        require(VerifyValidityOfMessage(_proof, _v, _r, _s, _value, _nonce, alice), "proof that alice signed this message is not valid");
      }
      // Ensure the message from alice is valid
      // if the challenge is successful, update the lastPaymentProof
      lastPaymentProof = Payment({nonce: _nonce, value: _value});
      return true;
  }
 ```
 
 Only after the challenge period is done, can either party call the `finalize` function and get paid.

 ```javascript
   // Used to finalize payment of the channel
  function FinalizeChannel() external returns(bool) {
    // Ensure the challenge period exists
    require(startChallengePeriod > 0, "channel is not in closed state");
    // Ensure the challenge period has ended
    require(startChallengePeriod + challengePeriodLength < now, "challenge period has not ended");
    
    // Finally transfer the ether
    bob.transfer(lastPaymentProof.value);
    alice.transfer(amountDeposited - lastPaymentProof.value);
    
    return true;
  }

 ```

 Finally we have to cover another edge case, the fact that bob could be unresponsive or decide to never sign a single message from Alice. Thus we need a timeout mechanism so Alice can recover her funds if the channel never gets closed.

 ```javascript
   function TimeoutClose() external returns(bool) {
    // Ensure we reached the timeout period
    require(now > startDate + timeout  , "timeout on the channel has not been reached");
    // Ensure the channel is not in the closed / challenge period
    require(startChallengePeriod == 0, "the channel is in the closed state");
    // Finally transfer all of the funds to alice as there were presumably no message transferred from Bob to Alice
    alice.transfer(amountDeposited);
    return true;
  }
```

### CLI tool

To make this a bit more concrete, I've created a small [CLI tool](https://github.com/Dev43/payment-channel) in Golang exemplifying our example with Alice and Bob.

#### Getting Started

To get started using this CLI tool, you will need [ganache](https://truffleframework.com/ganache) or [ganache-cli](https://github.com/trufflesuite/ganache-cli), an amazing continuation of the testrpc project from Truffle that gives you a test blockchain to work with locally.

By default, the `payment-channel` tool will be looking for ganache on port 7545, so when starting up ganache, ensure to tell it what port to use:

```bash
ganache-cli --port 7545
```

Make sure to copy the mnemonic phrase, we will need this for our tool.

If on linux, an executable file is already created for you.
, if you are linux, a binary file is already created for you. All you need to do to run the project is `./payment-channel`.

If not on linux, you will also need to have a version of golang superior to `1.8`. Then in the repository, run `go get -v ./...` to fetch all the dependencies. Then do `go build` and this will create an executable binary for you.

#### Usage

This small CLI tool simulates a payment channel between Alice and Bob. 

To initialize our storage, run:

```bash
./payment-channel init [mnemonic]
```

Where [mnemonic] is replaced by the mnemonic given by ganache (in between double quotes as one string)

This will initialize our storage, and derive the public/private keys from the mnemonic that we will use.

Now we need to deploy the contract to the ganache testnet network

```bash
./payment-channel deploy
```

With the contract deployed, we can go ahead and open a payment channel between Alice and Bob

```bash
./payment-channel channel open 1000000000000000000
```

Here we just opened a channel with a value of 1 ether (1*10<sup>18</sup>) sent by Alice.

Now we can exchange as many signed messages between Bob and Alice. We need to give it the value we want to exchange, and the nonce of the transaction

```bash
./payment-channel channel sign 100000000000000000 --nonce 1
```

For simplicity, this command creates a signature from both parties (Alice and Bob) automatically. We can see the latest signatures from both parties outputted to STDOUT.

```json
"Latest proof: "channel.PaymentProof{
  Signatures: []channel.Signature{
    channel.Signature{
      Sig:  "0x7ec2edbb9ba9639a2da335064fc3de7545a0a0101f2a7ecb8220e8a313c05cd85961a109a0d049b11f99be65cd76efd95216f485c2d8cfd4cf8fd74365874bb300",
      From: "alice",
    },
    channel.Signature{
      Sig:  "0xc3cd09e1b35192d3bd8aed3172e4017cb2b3535aaa10cc52994445db54ec3ad82c62e845422dce825e3e1b3274e265dabc2e757924f8a446a5f63427553d7e2201",
      From: "bob",
    },
  },
  Amount: "100000000000000000",
  Date:   "2018-10-28 17:48:57.210120286 -0700 PDT m=+0.123536016",
  Nonce:  "1",
  Proof:  "0xcc49f7e87d1ef08906236eeaac65f96280018f60418ffafd5cc72b528dbaa761",
}
```

One can create way more signatures with an ever increasing nonce, they will be appended to an array of all signatures, all they have to do is the same operation but with a higher nonce.

Let's create a message where Bob receives more ether

```bash
./payment-channel channel sign 150000000000000000 --nonce 2
```

Now for the interesting bits. We can decide to close the payment channel with an earlier signature that benefits us. Let's close our payment channel with the first signature that we have:

```bash
./payment-channel channel close 0
```

Here we close the payment channel with the first signature we created, with nonce 1. This definitely benefits Alice, as she doesn't have to pay the extra ether. At this point, the challenge period has started.

Now Bob notices that Alice is trying to cheat her, Bob will challenge Alice and send the latest transaction he received from her. Keep in mind, this message has a higher nonce.

```bash
./payment-channel channel challenge alice
```

If the message is valid, it will overwrite Alice's assertion that she was supposed to only send 0.1 ether, now she will need to send 0.15 ether in total.

Now we need to finalize the payment channel but we are still in the challenge period. To do so we will do a little bit of magic. We will artificially increase the blockchain time (we can do this on testrpc and ganache) by calling our special `timewarp` command.

```bash
./payment-channel timewarp 1000
```

Because our challenge period is only 15 minutes, increasing the time by 1000 seconds is plenty. We can now call our finalize command:

```bash
./payment-channel channel finalize
```

At that point, the funds will be distributed to Bob and Alice.

## Problems with Payment Channels

### UI/UX

As you can see, creating/opening/closing/challenging/finalizing a payment channel is by no means easy. One needs to always look at what state the payment channel is in, whether we are close to the timeout or not and close it with the right signature at the right time. This makes it a headache when we think about the end user, but thankfully a lot of these tasks can be automated by software.

### Availability

Participating in a payment channel needs just that, participation. One needs to be connected most of the time and be able to track what is happening. It's great that we have a timeout but that still means that Alice cannot move her ether for that period of time, which is not only an inconvenience, it slows down the velocity of money.

### Backup

Also backing up those signatures is imperative. If one loses those signatures, and somehow the other party knows this, they can use it to their own benefit. This leads to some interesting exploits opportunities.

## Generalized state channels

Generalized State Channels are like the above app-specific state channels, except they are a generic framework. Generalized State Channels allow any state of any application to be combined into one, single state channel, all at the same time. (Similar to state channels, Generalized State Channels only work for the agreed upon participants.)

### Who is creating payment channels?

Raiden, Spankchain, Counterfactual

## Conclusion

Advantage:

- Cheaper
- "Instant finality"
- Privacy

Disadvantage

- Capacity 
- Availability
- Risk of losing signatures


## Sources

https://medium.com/coinmonks/understanding-counterfactual-and-the-evolution-of-payment-channels-and-state-channels-9e939d7c6f34
https://blog.gridplus.io/a-simple-Ethereum-payment-channel-implementation-2d320d1fad93
https://medium.com/@matthewdif/Ethereum-payment-channel-in-50-lines-of-code-a94fad2704bc
https://hackernoon.com/10-state-channel-projects-every-blockchain-developer-should-know-about-293514a516fd