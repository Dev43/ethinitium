pragma solidity 0.4.24;

contract SinglePaymentChannel {

  address public alice;
  address public bob;

  uint256 public startDate;
  uint256 public startChallengePeriod;
  uint256 public challengePeriodLength = 15 minutes;
  uint256 public amountDeposited;

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
    require(msg.value > 0);
    // ensure alice is the only one able to open the channel
    require(alice == msg.sender);
    // add bob's address
    bob = _bob;
    // startdate is now
    startDate = now;
    // we record the amount amountDeposited
    amountDeposited = msg.value;
    // Initiate the default payment proof
    lastPaymentProof = Payment({nonce: 0, value: msg.value});
  }


  // Anyone can close the channel
  function CloseChannel(
    bytes32 proof,
    uint8[2] v,
    bytes32[2] r,
    bytes32[2] s,
    uint256 value,
    uint256 nonce
  ) external returns(bool) {
    // Ensure the message from alice is valid
    require(VerifyValidityOfMessage(proof, v[0], r[0], s[0], value, nonce, alice));
    // Ensure the message from bob is valid
    require(VerifyValidityOfMessage(proof, v[1], r[1], s[1], value, nonce, bob));
    // Update the last payment information
    lastPaymentProof = Payment({nonce: nonce, value: value});
    // Start the challenge period
    startChallengePeriod = now;
    return true;
  }

  // For a successful challenge, we need 2 signatures, one from bob and one from alice
  // Careful! This means that a VALID claim needs to have been signed by both parties.
  function Challenge(    
    bytes32 proof,
    uint8[2] v,
    bytes32[2] r,
    bytes32[2] s,
    uint256 value,
    uint256 nonce
    ) external  returns(bool) {
      // Ensure we are in the challenge period
      require(startChallengePeriod > 0);
      // Ensure we are in the challenge period
      require(startChallengePeriod + challengePeriodLength > now);
      // Ensure the message from alice is valid
      require(VerifyValidityOfMessage(proof, v[0], r[0], s[0], value, nonce, alice));
      // Ensure the message from bob is valid
      require(VerifyValidityOfMessage(proof, v[1], r[1], s[1], value, nonce, bob));
      // if the challenge is successful, update the lastPaymentProof
      lastPaymentProof = Payment({nonce: nonce, value: value});
      return true;
  }

  // Used to finalize payment of the channel
  function FinalizeChannel() external returns(bool) {
    // Ensure the challenge period exists
    require(startChallengePeriod > 0);
    // Ensure the challenge period has ended
    require(startChallengePeriod + challengePeriodLength < now);
    
    // Finally transfer the ether
    bob.transfer(lastPaymentProof.value);
    alice.transfer(amountDeposited - lastPaymentProof.value);
    
    return true;
  }

  // We ensure the message is valid, only coming from one address
  function VerifyValidityOfMessage(
    bytes32 proof,
    uint8 v,
    bytes32 r,
    bytes32 s,
    uint256 value,
    uint256 nonce,
    address originator
  ) public view returns(bool) {
    // there is a prefix to signed messages
    bytes memory prefix = "\x19Ethereum Signed Message:\n32";
    // hash our proof and the prefix
    bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, proof));
    // ecrecover the address of the signer
    address signer = ecrecover(prefixedHash,v,r,s);
    // We require the originator of the message to be the signer
    require(signer == originator, "signer is not the originator");
    //  we decide that a valid hash is the address of this contract, with the value and the nonce
    bytes32 h = keccak256(abi.encodePacked(address(this), value, nonce));
    // Ensure the proof matches
    require(h == proof, "The proof does not match");
    // Ensure the value here is not greater than what was amountDeposited
    require(value <= amountDeposited, "value exceeds what was amountDeposited");
    // Ensure the nonce used is greater than the last one
    require(nonce >= lastPaymentProof.nonce, "nonce is not greater to last nonce used");
    // If all is well, we return true
    return true;
  }

}
