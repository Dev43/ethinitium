pragma solidity ^0.4.24;

contract SinglePaymentChannel {

  address public alice;
  address public bob;

  uint256 public startDate;
  uint256 public startChallengePeriod;
  uint256 public challengePeriodLength = 15 minutes;
  uint256 public amountDeposited;
  uint256 public timeout = 1 days;

  struct Payment {
    uint256 nonce;
    uint256 value;
  }
  
  Payment public lastPaymentProof;

  constructor() public {
    alice = msg.sender;
  }

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

  // Used in case no messages get transferred from Alice to Bob or if Bob
  // never sends back a signature acknowledging the value alice sent
  // Before the timeout occurs, bob could send the message he received from alice and his own signature
  // to close the channel
  function Timeout() external returns(bool) {
    // Ensure we reached the timeout period
    require(now > startDate + timeout  , "timeout on the channel has not been reached");
    // Ensure the channel is not in the closed / challenge period
    require(startChallengePeriod == 0, "the channel is in the closed state");
    // Finally transfer all of the funds to alice as there were presumably no message transferred from Bob to Alice
    alice.transfer(amountDeposited);
    return true;
  }


  // We ensure the message is valid, only coming from one address
  function VerifyValidityOfMessage(
    bytes32 _proof,
    uint8 _v,
    bytes32 _r,
    bytes32 _s,
    uint256 _value,
    uint256 _nonce,
    address _originator
  ) public view returns(bool) {
    // there is a prefix to signed messages
    bytes memory prefix = "\x19Ethereum Signed Message:\n32";
    // hash our proof and the prefix
    bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, _proof));
    // ecrecover the address of the signer
    address signer = ecrecover(prefixedHash,_v,_r,_s);
    // We require the originator of the message to be the signer
    require(signer == _originator, "signer is not the originator");
    //  we decide that a valid hash is the address of this contract, with the value and the nonce
    bytes32 h = keccak256(abi.encodePacked(address(this), _value, _nonce));
    // Ensure the proof matches
    require(h == _proof, "The proof does not match");
    // Ensure the value here is not greater than what was amountDeposited
    require(_value <= amountDeposited, "value exceeds what was amountDeposited");
    // Ensure the nonce used is greater than the last one
    require(_nonce > lastPaymentProof.nonce, "nonce is not greater than the last");
    // If all is well, we return true
    return true;
  }
}
