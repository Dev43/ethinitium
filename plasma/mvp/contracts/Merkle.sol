pragma solidity ^0.4.0;


/**
 * @title Merkle
 * @dev Operations on Merkle trees.
 */

 // TAKEN FROM OMISEGO
library Merkle {
    /*
     * Internal function
     */
    
    /**
     * @dev Checks that a leaf is actually in a Merkle tree.
     * @param _leaf Leaf to verify.
     * @param _index Index of the leaf in the tree.
     * @param _rootHash Root of the tree.
     * @param _proof Merkle proof showing the leaf is in the tree.
     * @return True if the leaf is in the tree, false otherwise.
     */
    function verify(
        bytes32 _leaf,
        uint256 _index,
        bytes32 _rootHash,
        bytes _proof
    ) internal pure returns (bool) {
        // Check that the proof length is valid.
        require(_proof.length % 32 == 0, "Invalid proof length.");

        // Compute the merkle root.
        // Sibling of our current leaf
        bytes32 proofElement;
        // Our current leaf
        bytes32 computedHash = _leaf;
        // index of our transaction
        uint256 index = _index;
        for (uint256 i = 32; i <= _proof.length; i += 32) {
        // We go through every the proof and extract the proof element
        // using assembly to save on gas cost (mload loads 32 bytes in memory, exactly a hash size!)
            assembly {
                proofElement := mload(add(_proof, i))
            }
            // From there we look atr what index we are, if we are at an even index then our computedHash is the left child and the proofElement is the right child
            if (_index % 2 == 0) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                // or the opposite
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
            // go up one level in the tree
            index = index / 2;
        }

        // Check that the computer root and specified root match.
        return computedHash == _rootHash;
    }
}
