## Plasma root chain contract


> The Plasma contract maintains the following data structures:

> * The **owner** (set at initialization time)
> * A **list of Plasma blocks**, for each block storing (i) the Merkle root, (ii) the time the Merkle root was submitted.
> * A **list of submitted exit transactions**, storing (i) the submitter address, and (ii) the UTXO position (Plasma block number, txindex, outindex). This must be stored in a data structure that allows transactions to be popped from the set in order of priority.

> A Plasma block can be created in one of two ways. First, the operator of the Plasma chain can create blocks. Second, anyone can deposit any quantity of ETH into the chain, and when they do so the contract adds to the chain a block that contains exactly one transaction, creating a new UTXO with denomination equal to the amount that they deposit.

> The contract has the following functions:

> * `submitBlock(bytes32 root)`: submits a block, which is basically just the Merkle root of the transactions in the block
> * `deposit()`: generates a block that contains only one transaction, generating a new UTXO into existence with denomination equal to the `msg.value` deposited
> * `startExit(uint256 plasmaBlockNum, uint256 txindex, uint256 oindex, bytes tx, bytes proof, bytes confirmSig)`: starts an exit procedure for a given UTXO. Requires as input (i) the Plasma block number and tx index in which the UTXO was created, (ii) the output index, (iii) the transaction containing that UTXO, (iv) a Merkle proof of the transaction, and (v) a confirm signature from each of the previous owners of the now-spent outputs that were used to create the UTXO.
> * `challengeExit(uint256 exitId, uint256 plasmaBlockNum, uint256 txindex, uint256 oindex, bytes tx, bytes proof, bytes confirmSig)`: challenges an exit attempt in process, by providing a proof that the TXO was spent, the spend was included in a block, and the owner made a confirm signature.

> `startExit` must arrange exits into a priority queue structure, where priority is normally the tuple (blknum, txindex, oindex) (alternatively, blknum * 1000000000 + txindex * 10000 + oindex). However, if when calling exit, the block that the UTXO was created in is more than 7 days old, then the blknum of the oldest Plasma block that is less than 7 days old is used instead. There is a passive loop that finalizes exits that are more than 14 days old, always processing exits in order of priority (earlier to later).

> This mechanism ensures that ordinarily, exits from earlier UTXOs are processed before exits from older UTXOs, and particularly, if an attacker makes a invalid block containing bad UTXOs, the holders of all earlier UTXOs will be able to exit before the attacker. The 7 day minimum ensures that even for very old UTXOs, there is ample time to challenge them.
