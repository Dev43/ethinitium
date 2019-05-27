pragma solidity ^0.4.24;

import "./Heap.sol";
import {Merkle} from "./Merkle.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/math/Math.sol";
import "openzeppelin-solidity/contracts/cryptography/ECDSA.sol";
import {BytesLib} from "solidity-bytes-utils/contracts/BytesLib.sol";
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

  uint256 public lastWeekOldBlock;

// // Exittransactions storing (i) the submitter address, and (ii) the UTXO position (Plasma block number, txindex, outindex).
  struct ExitTransaction {
    address submitter;
    uint256 plasmaBlockNumber;
    uint256 txIndex;
    uint256 outIndex;
    // added for simplicity
    uint256 amount;
    // added for challenges
    bool challenged;
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


  constructor() public {
    // The owner (set at initialization time)
    owner = msg.sender;
    // Initialize the priority queue
    heap = new Heap();
  }

  /// A Plasma block can be created in one of two ways. First, the operator of the Plasma chain can create blocks. 
  /// Second, anyone can deposit any quantity of ETH into the chain, and when they do so the contract adds to the chain a block that contains exactly one transaction,
  // creating a new UTXO with denomination equal to the amount that they deposit.

  event NewBlock(
    uint256 _number,
    bytes32 indexed _blockHash
  );

  // event Deposit(
  //   address indexed from,
  //   uint256 indexed blockNumber,
  //   uint256 amount
  // );
  event Deposit(
    address  from,
    uint256  blockNumber,
    uint256 amount
  );

  event ExitInProgress (address indexed from, uint256 priority, uint256 amount);

  // submitBlock(bytes32 root): submits a block, which is basically just the Merkle root of the transactions in the block
  function submitBlock(bytes32 root) onlyOwner external {
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

  // UTXO position (Plasma block number, txindex, outindex). -  menaing what plasma block number the utxo was created, at what transaction index, at what outindex it was (can be multiple outindices)
  function startExit(uint256 plasmaBlockNum, uint256 txindex, uint256 oindex, bytes fullTx, bytes proof, bytes confirmSig) public {
    
    require(exits[plasmaBlockNum].plasmaBlockNumber != 0, "exit already exists");

    bytes32 blockHash = plasmaBlocks[plasmaBlockNum].blockHash;

    // ensure exit does not exist already

    // need to seperate the important information in a transaction thsat is RLP encoded
    // A transaction is of the form:
      /* [blknum1, txindex1, oindex1, sig1, # Input 1 
          blknum2, txindex2, oindex2, sig2, # Input 2
          newowner1, denom1,                # Output 1 
          newowner2, denom2,                # Output 2
          fee] */
    RLPReader.RLPItem[] memory decodedTx = fullTx.toRlpItem().toList();

    // Out of all of these, we want index 8 where we have the "new owner address" 
    // index 9 has the value of it
    ExitTransaction memory exitTx = ExitTransaction({
      submitter: decodedTx[8 + 2 * oindex].toAddress(),
      plasmaBlockNumber: plasmaBlockNum,
      txIndex: txindex,
      outIndex: oindex,
      amount : decodedTx[9 + 2 * oindex].toUint(),
      challenged: false
      // amount?
    });

    uint256 exitAmount = decodedTx[9 + 2 * oindex].toUint();

    require(exitAmount != 0, "you cannot exit a UTXO with 0 value");


    bool isMultipleUTXO = decodedTx[4].toUint() > 0;

    // ensure that the msg sender is the one that owns the utxo (from tx)
    require(exitTx.submitter == msg.sender);

    // Proof is the fulle merkle proof (merged together) we need to valiate that the root of the merkle tree is the root of the deposit block
    bytes32 txHash = keccak256(fullTx);
    // We verify the txn hash at the bottom of the tree, hash it with it's sibling and go up the tree to verify the merkleRoot.
    require(Merkle.verify(txHash, txindex, blockHash, proof), "merkle proof not verified");
    // Need to validate signature
    // We need to validate a whole bunch of signatures, the first one is the one for this transaction (SIG1), the second one is the confirm signature (CONFSIG) which is the hash of the txHash and rootHash
    require(validateSigs(txHash, keccak256(abi.encodePacked(txHash, blockHash)), confirmSig, isMultipleUTXO));

    // 
    // Need to add exits in a priority queue structure
    // startExit must arrange exits into a priority queue structure, where priority is normally the tuple (blknum, txindex, oindex) 
    //(alternatively, blknum * 1000000000 + txindex * 10000 + oindex). However, if when calling exit, the block that the UTXO was created in is more than 7 days old, 
    //then the blknum of the oldest Plasma block that is less than 7 days old is used instead. There is a passive loop that finalizes exits that are more than 14 days old,
    // always processing exits in order of priority (earlier to later).

    uint256 priority;
    if (plasmaBlocks[plasmaBlockNum].timestamp - now > 7 days) {
      updateWeekOldBlock();
      // COULD LEAD TO OVERWRITES IF txIndex and oIndex are the same.
      priority = lastWeekOldBlock * 1000000000 + txindex * 10000 + oindex;
    } else {

      priority = plasmaBlockNum * 1000000000 + txindex * 10000 + oindex;
    }

    // TODO CHECK THIS AGAIN -- all we need is a way for it tpo be popped first
    // Encode the blocknumber inside the main data structure :)
    // Cool trick taken form OMISEGO
    heap.insert(priority);

    exits[priority] = exitTx;

    emit ExitInProgress(msg.sender, priority, exitAmount);
  }

  // function to update the last week old block
  function updateWeekOldBlock() internal returns(uint256) {
    // start at the last know week old block
      uint256 lastBlockNumber = lastWeekOldBlock;

      // while the difference is over 7 days, keep going until it isnt
      while (now - plasmaBlocks[lastBlockNumber].timestamp > 7 days) {
        lastBlockNumber++;
        // We are at the tip of the chain
        if(lastBlockNumber == plasmaBlocks.length) {
          break;
        }
      }
      // assuming we didn't break, we record what was the last block with a 7 day difference.
      lastWeekOldBlock = lastBlockNumber;
  }
  
  function validateSigs(bytes32 txHash, bytes32 confirmProof, bytes signatures, bool isMultipleUTXO) internal pure returns(bool) {
    // Signatures can be at most 260 -- and have to be a multiple of 65
    require(signatures.length % 65 == 0, "sig length is not divisible by 65");
    require(signatures.length <= 260, "sig length is too long");
    // As the signatures are all concatenated together, we need to seperate them
    bytes memory firstSignature = BytesLib.slice(signatures, 0, 65);
    bytes memory firstConfSig = BytesLib.slice(signatures, 130, 65);
    require(ECDSA.recover(txHash, firstSignature) == ECDSA.recover(confirmProof, firstConfSig), "first signatures do not match");

    if(isMultipleUTXO) {
      // Look at the pother utxo and ensure the signatures are valid
      bytes memory secondSignature = BytesLib.slice(signatures, 65, 65);
      bytes memory secondConfSig = BytesLib.slice(signatures, 195, 65);
      require(ECDSA.recover(txHash, secondSignature) == ECDSA.recover(confirmProof, secondConfSig), "second signatures do not match");
    } 

    return true;
  }

  // There is a passive loop that finalizes exits that are more than 14 days old, always processing exits in order of priority (earlier to later).
  function finalizeExit() public {

    // Get the next element to exit

    uint256 priority = heap.getMax();
    // get the exit in question
  
    ExitTransaction memory currExit = exits[priority];

    // If the exit of the blocknumber is more than 14 days old, then exit it now

    while(plasmaBlocks[currExit.plasmaBlockNumber].timestamp + 14 days < now){
      // remove it from the heap
      // REFACTOR THIS
      uint newPriority = heap.removeMax();
      
      if(currExit.challenged == true) {
        // delete the exit
        delete exits[newPriority];
        continue;
      }
      
      // Get the amount to send
      uint256 amount = currExit.amount;
      // Get the submitter to send to
      address toSendTo = currExit.submitter;
      // delete the exit (so no reentrancry possible)
      delete exits[newPriority];
      // Transfer the funds

      toSendTo.transfer(amount);
      // Find the next exit
      currExit = exits[heap.getMax()];

    }



  }


  // challengeExit(uint256 exitId, uint256 plasmaBlockNum, uint256 txindex, uint256 oindex, bytes tx, bytes proof, bytes confirmSig): 
  //challenges an exit attempt in process, by providing a proof that the TXO was spent, the spend was included in a block, and the owner made a confirm signature.
  // We don't need the oIndex as all we need to see is that the transaciton has been spent, not where trhe output is.
  function challengeExit(uint256 exitId, uint256 plasmaBlockNum, uint256 txindex, uint256 oindex, bytes fullTx, bytes proof, bytes confirmSig) external {
    // Get the exit with the specific id 
    ExitTransaction storage challengedExit = exits[exitId];

    // Get the plasma block where the UTXO was Spent
    bytes32 challengeBlockHash = plasmaBlocks[plasmaBlockNum].blockHash;

    
    // Decode the transaction where this happened (do i need to do something with this??)
    RLPReader.RLPItem[] memory decodedTx = fullTx.toRlpItem().toList();
    // Check the transaction is actually submitted by the submitter --> or at least creates a new UTXO for the submitter.
    require(decodedTx[8 + 2 * oindex].toAddress() == challengedExit.submitter);
    // Get the transaction hash
    bytes32 txHash = keccak256(fullTx);

    // We need to validate that the confirm signatures match and are signed by the person trying to make the exit.
    // abi.encodePacked(txHash, challengeBlockHash) is our proof that was signed in the confirmSig
    require(challengedExit.submitter == ECDSA.recover(keccak256(abi.encodePacked(txHash, challengeBlockHash)), confirmSig), "challenge signature not coming from exit submitter");

    // we need to confirm that the transaction was included in a block (means using proof and computing the merkle proof)
    require(Merkle.verify(txHash, txindex, challengeBlockHash, proof), "challenge merkle proof not verified");

    // Delete the exit
    // CANNOT SIMPLY DELETE THE EXIT AS IT IS IN THE HEAP!!!! Look at a flag maybe, or deleting something else 
    challengedExit.challenged = true;
  // HERE WE CAN ADD A BOUNTY THAT GETS PAID OUT
  }
}
