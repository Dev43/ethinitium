pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract PlasmaMVP is Ownable {

//   //  for each block storing (i) the Merkle root, (ii) the time the Merkle root was submitted.
//   struct PlasmaBlock {
//     bytes32 blockHash;
//     uint256 timestamp;
//   }

// //  "list" of Plasma blocks, here we use a mapping 
//   mapping(uint256 => Block) plasmaBlocks;

// // storing (i) the submitter address, and (ii) the UTXO position (Plasma block number, txindex, outindex).
//   struct ExitTransaction {
//     address submitter;
//     uint256 plasmaBlockNumber;
//     uint256 txIndex;
//     uint256 outIndex;
//   }

//   // need a priority Queue
//   //This must be stored in a data structure that allows transactions to be popped from the set in order of priority.


// // list of submitted exit transactions
//   mapping(uint256 => ExitTransaction) exitTransactions;

  constructor() {
  }
}
