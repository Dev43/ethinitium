pragma solidity ^0.4.24;

import "./Heap.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/math/Math.sol";
import "openzeppelin-solidity/contracts/cryptography/ECDSA.sol";
import "openzeppelin-solidity/contracts/cryptography/MerkleProof.sol";
import "solidity-rlp/contracts/RLPReader.sol";

contract PlasmaMVP {

  using RLPReader for RLPReader.RLPItem;
  using RLPReader for bytes;
  using Math for uint256;
  using SafeMath for uint256;

// The owner (set at initialization time)
  address public owner;

  modifier onlyOwner {
    require(msg.sender == owner, "not the owner of the contract");
    _;
  }


// // Exittransactions storing (i) the submitter address, and (ii) the UTXO position (Plasma block number, txindex, outindex).
  struct ExitTransaction {
    address submitter;
    uint256 plasmaBlockNumber;
    uint256 txIndex;
    uint256 outIndex;
  }

  //  "list" of Plasma blocks,
  PlasmaBlock[] public plasmaBlocks;
// for each block storing (i) the Merkle root, (ii) the time the Merkle root was submitted.
  struct PlasmaBlock {
    bytes32 blockHash;
    uint256 timestamp;
  }

  // list of submitted exit transactions, maps the UTXO position of the exit w/ the exit transaction
  mapping (uint256 => ExitTransaction) public exits;

  // What actually needs to be stored in the priority queue? We need it's priority and the exit transaction UTXO position (to grab it fdrom the mapping)
  // Cool way to do it done by OmiseGo -- as they are numbers encode and decode them here
  Heap heap;


  constructor() {
    // The owner (set at initialization time)
    owner = msg.sender;
    // Initialize the priority queue
    heap = new Heap();
  }

  /// A Plasma block can be created in one of two ways. First, the operator of the Plasma chain can create blocks. 
  ///Second, anyone can deposit any quantity of ETH into the chain, and when they do so the contract adds to the chain a block that contains exactly one transaction,
  // creating a new UTXO with denomination equal to the amount that they deposit.

  event NewBlock(
    uint256 _number,
    bytes32 indexed _blockHash
  );

  event Deposit(
    address indexed from,
    uint256 indexed blockNumber,
    uint256 amount
  );

  // submitBlock(bytes32 root): submits a block, which is basically just the Merkle root of the transactions in the block
  function submitBlock(bytes32 root) onlyOwner {
    // Add the block to the blockchain
    plasmaBlocks.push(PlasmaBlock({
      blockHash: root,
      timestamp: now
    }));

    emit NewBlock(plasmaBlocks.length, root);
  }


  // deposit(): generates a block that contains only one transaction, generating a new UTXO into existence with denomination equal to the msg.value deposited
  function deposit() external payable {

    // !! COULD BE POROBLEM< what if blockHashes are the smae in the plasma chain???? -- need to add block number maybe
    // This is coming from  "A deposit block has all input fields, and the fields for the second output, zeroed out. 
    // To make a transaction that spends only one UTXO, a user can zero out all fields for the second input."
      bytes32 root = keccak256(abi.encodePacked(msg.sender, msg.value));
      plasmaBlocks.push(PlasmaBlock({
            blockHash: root,
            timestamp: now
      }));

      emit Deposit(msg.sender, plasmaBlocks.length, msg.value);
  }

  // startExit(uint256 plasmaBlockNum, uint256 txindex, uint256 oindex, bytes tx, bytes proof, bytes confirmSig): starts an exit procedure for a given UTXO. 
  //Requires as input 
  //(i) the Plasma block number 
  //tx index in which the UTXO was created, 
  //(ii) the output index, 
  //(iii) the transaction containing that UTXO,  --> RLP encoded
  /* [blknum1, txindex1, oindex1, sig1, # Input 1
 blknum2, txindex2, oindex2, sig2, # Input 2
 newowner1, denom1,                # Output 1
 newowner2, denom2,                # Output 2
 fee] */
  // (iv) a Merkle proof of the transaction, and 
  //(v) a confirm signature from each of the previous owners of the now-spent outputs that were used to create the UTXO. 9nboth tx sig and  confitmation sig

  /* startExit must arrange exits into a priority queue structure, where priority is normally the tuple (blknum, txindex, oindex) (alternatively,
   blknum * 1000000000 + txindex * 10000 + oindex). However, if when calling exit, the block that the UTXO was created in is more than 7 days old, 
   then the blknum of the oldest Plasma block that is less than 7 days old is used instead. 
  There is a passive loop that finalizes exits that are more than 14 days old, always processing exits in order of priority (earlier to later). */
  function startExit(uint256 plasmaBlockNum, uint256 txindex, uint256 oindex, bytes fullTx, bytes proof, bytes confirmSig) external {
    
    bytes32 root = plasmaBlocks[plasmaBlockNum].blockHash;

    // need to seperate the important information in a transaction thsat is RLP encoded
    // A transaction is of the form:
      /* [blknum1, txindex1, oindex1, sig1, # Input 1 --> CAN HAVE MULTIPLE INPUTS (NOT FOR MVP)
          blknum2, txindex2, oindex2, sig2, # Input 2
          newowner1, denom1,                # Output 1 --> the "to" --> CAN HAVE MULTIPLE OUTPUTS
          newowner2, denom2,                # Output 2
          fee] */
    RLPReader.RLPItem[] memory decodedTx = fullTx.toRlpItem().toList();

    // Out of all of these, we want index 8 where we have the "new owner address" 
    // index 9 has the value of it
    ExitTransaction memory exitTx = ExitTransaction({
      submitter: decodedTx[8].toAddress(),
      plasmaBlockNumber: decodedTx[0].toUint(),
      txIndex: decodedTx[1].toUint(),
      outIndex: decodedTx[2].toUint()
    });

    // ensure that the msg sender is the one that owns the utxo (from tx)
    require(exitTx.submitter == msg.sender);
    // Proof is the fulle merkle proof (merged together) we need to valiate that the root of the merkle tree is the root of the deposit block
    // Need to validate signature
    // 
    // Need to add exits in a priority queue structure
  }

  function finalizeExit() {

  }


  // challengeExit(uint256 exitId, uint256 plasmaBlockNum, uint256 txindex, uint256 oindex, bytes tx, bytes proof, bytes confirmSig): 
  //challenges an exit attempt in process, by providing a proof that the TXO was spent, the spend was included in a block, and the owner made a confirm signature.
  function challengeExit(uint256 exitId, uint256 plasmaBlockNum, uint256 txindex, uint256 oindex, bytes fullTx, bytes proof, bytes confirmSig) external {

  }
}
