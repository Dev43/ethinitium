# Payment Channels

## What is a payment channel?

### Definition

> A Micropayment Channel or Payment Channel is class of techniques designed to allow users to make multiple Bitcoin transactions without commiting all of the transactions to the Bitcoin block chain. <sup>[1](https://en.bitcoin.it/wiki/Payment_channels)</sup> In a typical payment channel, only two transactions are added to the block chain but an unlimited or nearly unlimited number of payments can be made between the participants.

The main takeaway from this definition is the fact that payment channels can reduce a large volume of transactions between two parties to only 2 that matter (most of the time), the opening and closing of the payment channel.

### Rationale

Why are payment channels even necessary? Taking the example of Ethereum, we all know that we can transfer ether and tokens by sending between each other by crafting transactions and sending them to the network. Why are payment channels a better solution?

1. **Ethereum is slow**. Let's calculate the current maximal transaction per second (tps) that Ethereum can handle: assuming a block gas limit of 8000000 (at the time of writing) and a simple ether transaction costing 21000 gas units, we can calculate how many transactions fit in a block by dividing them together: `8000000 / 21000 =~ 380`. This means that at most, a single ethereum block can hold 380 transactions. With a block time of around 15 seconds, we calculate the tps: `381/15 =~ 25`. 25 tps is the best case scenario where every user is sending a simple ether transfer, here we are not counting on "function calls", contract creation transactions and general data saving transactions. By counting those in, we see and effective average tps of about 15 transactions per second.
2. **Micropayments are expensive**. With a gas limit of 21000 and a gas price that varies, we can have our simple ether transaction cost fraction of a cent to multiple dollars. This makes sending low value transactions (micropayments) infeasible. Here we are also not taking into account token transfers which usually cost upwards of 50000 gas units.
3. **Storage optimization**. Blockchain full nodes store the entire history of the blockchain since the genesis block. As more transactions are being added, the storage requirement increases at an accelerating pace. Payment channels help reduce this acceleration by including only the transactions that matter.
4. **Bandwidth requirements**. Every transaction sent to an Ethereum node gets dispersed to other nodes using the gossip protocol. Now this is sustainable if you don't have that many transactions flowing through the network but as more people join the network, this can become a bottleneck. This also leads to pending transaction pool bloat, and requires miners to have a better bandwidth allocation.
5. **Privacy**. Due to its account system, it is extremely easy to track all transactions coming from a specific address (bitcoin is incrementally better with UTXO's). Payment channels actually allow a certain amount of privacy between the two parties. As it is simply exchanging a signed message between two people, normal encryption paradigms can be used. The two parties can decide to encrypt their communications and even encrypt the contents of the message with the other party's PGP key. The only two points that need to be publicly accessible are the opening and closing of the channel.

## Different payment channel designs

In its essence, a payment channel is an exchange of valid signed transactions (we will call them **messages**) that send ether/tokens from one person to another. In this article, we will be using Alice and Bob as our examples.  If Alice and Bob both have a valid message from each other, they (or anyone else as a matter of fact) can send it to the blockchain while the payment channel is open.

There are multiple types of payment channels that one can implement, let's explore a few of them in detail.

### Simplest "payment channel" (no smart contract)

This example will be very brief but is simply there to get us accustomed to the concepts. Alice could enter into an agreement with Bob that she will be sending him valid signed Ethereum transactions and tells Bob not to spend it right away. As bob does more work, Alice sends him a new signed transaction with a higher ether value and the same **nonce**. It's important that the transaction has the same nonce, or else Bob could easily take all of the transactions and send them to the network, thus getting paid way more than Alice would like. Bob, at any time, can decide to send this transaction to the network to get the full payout. Of course, this solution is very flawed as Alice can simply send Bob a valid signed message and then drain her account of ether. A large amount of trust is needed in this solution, which makes it useless.

### Unidirectional payment channel

## How they work
Here by unidirectional, we mean the transfer of ether goes only **from one party to another** (here from Alice to Bob) and the value can only be **increasing**.

To create such a channel, we can create a smart contract that locks Alice's funds for a specific amount of time. There is a great [article](https://medium.com/@matthewdif/Ethereum-payment-channel-in-50-lines-of-code-a94fad2704bc) of such a smart contract written by Matthew Di Ferrante [@matthewdif](https://medium.com/@matthewdif) on the subject. In a very succinct way, Di Ferrante explains to us the mechanism of this unidirectional channel and provides a very simple solidity contract.

To explain it simply, to achieve such a channel, Alice locks the total amount of ether she is willing to pay to Bob. To "pay" Bob,she needs to craft a new message (again valid and signed) that is directing the smart contract that to pay bob a certain value taken from the locked up funds.

With this message in hand, Bob can verify that this message is valid and would lead to him getting the right value of ether transferred to him.

This is important to understand: Bob can cash out at any time as long as he has a valid message, although it would be more beneficial for Bob to keep the channel open, as he could get more money if Alice sends him more payments.

This is almost perfect. It can lead to a very undesirable fate for Alice. As she has her money locked in this contract, it is very possible that Bob never closes the channel. It could be that Bob is doing this maliciously or simply that Bob is not available/online anymore.

To solve this edge case, Di Ferrante introduces a general timeout to the channel. Assuming the channel was never closed and times out, Alice would get the totality of ether that she sent. This ensures that Bob is incentivised to close the channel before it times out.

Now this solution only works for **monotonically increasing unidirectional** payment channels, meaning that Alice is sending ether to Bob and the next message will need to be of higher value than the last (or else Bob can pick and choose which message has the highest value for him and close the channel).

### Unidirectional payment channel with a challenge period

In another great and more hands on [article](https://blog.gridplus.io/a-simple-Ethereum-payment-channel-implementation-2d320d1fad93) written by Alex Miller [@asmiller1989](https://blog.gridplus.io/@asmiller1989), we see a slightly more complex logic.

In his V2 version of the payment channel, he introduces a few improvements:

- Nonces: for every new message add a counter (nonce) to the signed message. The message with the higher nonce is the latest message.
- Challenge period: Any party (and anyone) can challenge the message used when the channel was closed

This design will be further explained later in this article.

## Bidirectional payment channels

Bidirectional payment channels are very similar to unidirectional payment channels with the main difference is that you need both participants to input a value in ether. The message used now directs how the smart contract should split the ether between Alice and Bob. For example, let us assume Alice and Bob have contributed 1 ether each in the payment channel, for a grand total of 2 ether. When Alice wants to pay Bob 0.5 ether, Alice sends a message that divides the 2 ether in between them, i.e. 0.5 ether to herself and 1.5 to bob.

This channel needs to be able to be closed by both parties, but again it should have a challenge period and nonce relating to what is the actual latest message.

### Technical example

#### A semi-bidirectional payment channel

Why semi-bidirectional? I've simplified this example so only Alice needs to deposit ether into the channel, but the amount sent to bob does not need to monotonically increase, it can also decrease. You can think of it as Alice is a customer and Bob is a merchant. Alice will be paying bob most of the time, but Bob can actually reimburse alice on some expenses. We are allowed to have a two way flow, granted that Alice already sent a message to Bob.

We will be creating a simple payment channel smart contract that will achieve these properties. If you want the full solution, please find it [here]().

In our example, Alice deploys our smart contract. She calls the `OpenChannel` function where she declares the other party as Bob and she deposits a total maximal sum that the contract holds. For simplicity, we won't allow Alice or Bob to add more funds into the contract after the channel is open.

```js
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

*For simplicity of this example, we have hardcoded the challenge time period to last 15 minutes and the total timeout of the channel to last 1 day. Also, the design of this payment channel is such that you need to redeploy a brand new contract to start a new payment channel. Of course this is not scalable and not the best practice, this is only for to simplify the example.*

We have now opened a payment channel between Bob and Alice. Now for Alice to start paying Bob, all she has to do is to sign a massage of intent saying that she will be sending Bob a certain amount of ether.

In our solution, the message that needs to be signed includes three pieces of information:

- the `address` of the payment channel contract
- the `value` that Alice is willing to send to Bob
- the `nonce` of the message (simple message counter)

Why is the contract address needed? Remember that we will be signing a message with our private key. This message needs to be unique and simply signing the value and the nonce together means that I can use this exact signature coming from you, in another payment channel. Adding the contract address here makes it so it is truly (or almost) a one time signature. 

Now to create a digital signature using these three values and either Alice's or Bob's private key, we need to bring this message down to 32 bytes by using a cryptographic hash function, Keccak256. To create a valid 32 byte string to sign, we concatenate the the contract address, value and nonce together and take the Keccak256 hash. This gives us a 32 byte digest which we will call *proof*, with which we can sign using a private key.

In the [tests](https://github.com/Dev43/ethinitium/blob/master/payment_channels/simple_payment_channel/test/payment_channel.js) associated with our contract, we've created a function to do just that.

```js
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

Alice now signs such a message with her private key and sends it to Bob. She needs to send the signature and the three other values, address, value and nonce to Bob. Bob can now verify this message by concatenating the three arguments, hashing them together and verifying that the signature really came from Alice. Bob can now do the same, sign the message and send it to Alice. Now both of them have the same message but signed by two different parties. At this point one can assume that the payment has officially ocurred.

*Remember, "sending" the transaction can be done using encrypted channels, email, SMS, even a printed out piece of paper!*

At anytime now, either of them are able to close the channel. All that either party needs to do is to call the `Close` function on the smart contract with both valid signatures and the respective values (nonce and value). From there, the smart contract will verify both signatures, update the latest proof sent to it and start the challenge period.

```js
  // Anyone can close this channel but needs to give in both signatures of the proof
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

We've set a 15 minute "challenge period" where the opponent (or actually anyone) with two valid signatures will be able to change the outcome of the payment.  As multiple messages get sent between bob and alice, it'd be trivial for any of them to send in the message that makes them the most money. This where the **nonce** comes in. By ensuring that the nonce goes up every single time (this can be enforced server side), and enforcing the fact the the highest nonce wins on the smart contract, you cannot get anyone to cheat and send in an old signature that makes them the most money as the other one will always be able to overwrite it with the true latest signature.

Also, we cannot let only one of the parties be able to sign the message as it would mean that party can create as many messages with higher nonces as they want. To successfully challenge the closing of a channel, we've made it so one needs to provide the other party's signature with a higher nonce for it to be valid.

```js
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
    // if the challenge is successful, update the lastPaymentProof
    lastPaymentProof = Payment({nonce: _nonce, value: _value});
    return true;
}

```

After a successful challenge, the latest proof will be overwritten with the one sent. This ensures that Bob (or Alice) agree on the final outcome of the channel.

After the challenge period is done, either party call the `FinalizeChannel` function and get paid.

```js
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

 Finally we have to cover one last edge case, the fact that Bob could be unresponsive or decide to never sign a single message from Alice. Thus we need a timeout mechanism so Alice can recover her funds if the channel never gets closed.

```js
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

To get started using this CLI tool, you will need [ganache](https://truffleframework.com/ganache) or [ganache-cli](https://github.com/trufflesuite/ganache-cli). Ganache is an amazing continuation of the testrpc project from Truffle that gives you a test blockchain to work with locally.

By default, the `payment-channel` tool will be looking for Ganache on port 7545, so when starting up ganache, ensure to tell it what port to use:

```sh
ganache-cli --port 7545
```

Make sure to copy the mnemonic phrase, we will need this for our tool.

If you are on linux, an executable file is already created for you. All you need to do to run the project is `./payment-channel`.

If not on linux, you will also need to have a version of golang superior to `1.8`. Then in the repository, run `go get -v ./...` to fetch all the dependencies. Then do `go build` which will create an executable binary for you called `payment-channel`.

#### Usage

This small CLI tool simulates a payment channel between Alice and Bob.

First we need initialize our storage, run:

```sh
./payment-channel init [mnemonic]
```

Where [mnemonic] is replaced by the mnemonic given by ganache (in between double quotes as one string i.e "lamp, ..., umbrella")

This will initialize our storage, and derive the public/private keys from the mnemonic that we will use.

Now we need to deploy the contract to the ganache testnet network.

```sh
./payment-channel deploy
```

With the contract deployed, we can go ahead and open a payment channel between Alice and Bob.

```sh
./payment-channel channel open 1000000000000000000
```

Here we just opened a channel with a value of 1 ether (1*10<sup>18</sup>) sent by Alice.

Now we can exchange as many signed messages between Bob and Alice. We need to give it the value we want to exchange, and the nonce of the transaction

```sh
./payment-channel channel sign 100000000000000000 --nonce 1
```

For simplicity, this command creates a signature from both parties (Alice and Bob) automatically. We can see the latest signatures from both parties outputted to STDOUT.

```go
Latest proof: channel.PaymentProof{
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

One can create as many signatures as they want with an ever increasing nonce. Those signatures will be appended to an array of all signatures, all they have to do is the same operation but with a higher nonce. To view all the signatures (and data saved), you can lookup the `storage.json` file.

Now let's create a message where Bob receives more ether

```sh
./payment-channel channel sign 150000000000000000 --nonce 2
```

Now for the interesting bits. We can decide to close the payment channel with an earlier signature that benefits us. Let's close our payment channel with the first signature that we have where Bob is getting 0.1 ether and alice keeps 0.9 of it all.

```sh
./payment-channel channel close 0
```

Here we close the payment channel with the first signature we created, with nonce 1. This definitely benefits Alice, as she doesn't have to pay the extra ether. At this point, the challenge period has started.

Now Bob notices that Alice is trying to cheat her, Bob will challenge Alice and send the latest transaction he received from her. Keep in mind, this message has a higher nonce.

```sh
./payment-channel channel challenge alice
```

If the message is valid, it will overwrite Alice's assertion that she was supposed to only send 0.1 ether, now she will need to send 0.15 ether in total.

Now we need to finalize the payment channel but we are still in the challenge period. To do so we will do a little bit of magic. We will artificially increase the blockchain time (we can do this on testrpc and ganache) by calling our special `timewarp` command.

```sh
./payment-channel timewarp 1000
```

Because our challenge period is only 15 minutes, increasing the time by 1000 seconds is plenty. We can now call our finalize command:

```sh
./payment-channel channel finalize
```

At that point, the funds will be distributed to Bob and Alice.

## Payment Networks

Now what if we connected multiple bi-directional payment channels together and somehow made it so that anyone connected to such a network can interact with another person in that network? This is what **payment networks** aim to achieve (most notable in ethereum is [Raiden](https://raiden.network/))

How is this done? Essentially you let users relay the payment. Imagine we have Alice, Bob and Carol. Imagine there is a payment channel between Alice and Bob and Bob and Carol. For Alice to be able to pay Carol, she would need to relay that information to Bob and ask Bob to pay Carol. Now this relies on trusting Bob, which is not a good way to go forward.

So to pay Carol, Alice first creates a secret, concatenates the value on it and hashes it. Alice then creates a message saying the she is paying Bob a certain value if he reveals this secret (she sends in the value and the hash of the secret).  Alice tells Carol what the secret is using an encrypted channel that Bob cannot snoop in. Bob now creates a payment to Carol with the same conditions.
To get paid, Carol needs to reveal the secret to Bob, which he then can reveal to Alice.

In this way, you can have a multi-hop network where anyone who participates in this network is able to transact with anyone else in that network.

## Problems with Payment Channels

Payment channels at first glance seem like the ultimate Layer 2 scalability solution. We can ensure almost instant finality of transactions, create micro-payments and transfer micro-payments to another party at incredible speeds and extremely low cost. But larger problems persist.

### UI/UX

As you can see, creating/opening/closing/challenging/finalizing a payment channel is by no means easy. One needs to always verify at what state the payment channel is in, whether we are close to the timeout or not and close it with the right signature. This makes it a headache when we think about the end user, but thankfully a lot of these tasks can be automated by software.

### Availability

Participating in a payment channel needs just that, participation. One needs to be connected most of the time and be able to track what is happening. It's great that we have a timeout but that still means that Alice cannot move her ether for that period of time, which is not only an inconvenience, it slows down the velocity of money.

### Velocity of money

Payment channels require participants to lock funds for a predetermined amount of time (this can also be extended as needed). Now this potentially reduces the velocity of money and also practically means that a regular user won't want to lock up a very large amount of funds for a long time.

### Backup

Also backing up those signatures is imperative. If one loses those signatures, and somehow the other party knows this, they can use it to their own benefit. This leads to some interesting and dangerous exploits opportunities.

## Generalized state channels

In this article we looked at a payment channel using ether only. Of course this would also work with Tokens (Miller has a great [example](https://blog.gridplus.io/a-simple-Ethereum-payment-channel-implementation-2d320d1fad93)), or even Non Fungible Tokens (NFTs).

In fact, these channels can be generalized to any state transition that we want. Although non-trivial to implement, we can make it so before we enter into a payment channel, we agree on what state transitions are allowed and send signed messages between parties. This is what [Counterfactual](https://www.counterfactual.com/), [Spankchain](https://spankchain.com/) and others are trying to achieve. Lots of great development is coming from them.

## Conclusion

In this article we've explored a few possible design for payment channels and done a technical deep dive on an implementation of a bi-directional payment channel. If there is one thing that I want you to take away are the emergent properties that this Layer 2 solution achieves. Under optimal circumstances, a payment channel would require at most 2-3 transactions (open/close) and be able to reduce a very large amount of transactions that actually hit the blockchain. It is not a perfect solution though, as it means that both parties need to be available and online. Nonetheless, having quasi-instant finality while paying with cryptocurrencies is extremely attractive, and already we see implementations of it to [pay for coffee](https://www.youtube.com/watch?v=ZlyPNABZtHk)


## Sources

https://medium.com/coinmonks/understanding-counterfactual-and-the-evolution-of-payment-channels-and-state-channels-9e939d7c6f34
https://blog.gridplus.io/a-simple-Ethereum-payment-channel-implementation-2d320d1fad93
https://medium.com/@matthewdif/Ethereum-payment-channel-in-50-lines-of-code-a94fad2704bc
https://hackernoon.com/10-state-channel-projects-every-blockchain-developer-should-know-about-293514a516fd