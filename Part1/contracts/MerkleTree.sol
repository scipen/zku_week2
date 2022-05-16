//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form (bottom to top)
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root
    uint256 private n; // number of levels in the tree (2**n leaves)
    /*
    n=2
       6
     4   5
    0 1 2 3
    */

    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves
        n = 3;
        uint m = n+1;  // number of layers
        hashes = new uint256[](2**m-1);

        for (uint i = 0; i < m; ++i) {  // over layers
            for (uint j = 0; j < 2**(m-i-1); ++j) {  // over nodes within layer
                uint idx = (2**m - 2**(m-i)) + j;

                if (i == 0) {  // bottom layer
                    hashes[idx] = 0;
                } else {
                    uint childLeftIdx = (2**m - 2**(m-(i-1))) + 2*j;
                    uint childRightIdx = (2**m - 2**(m-(i-1))) + 2*j + 1;
                    hashes[idx] = PoseidonT3.poseidon([hashes[childLeftIdx], hashes[childRightIdx]]);
                }
            }
        }

        root = hashes[2**m-1-1];
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        require(index < 2**n, "tree is full");
        uint m = n+1;  // number of layers
        
        // propagate updates to root
        uint parentHash = hashedLeaf;
        uint j = index;  // horizontal idx within layer
        uint J;  // number of nodes in layer
        uint nextIdx;  // next index of `hashes` to update
        for (uint i = 0; i < m-1; ++i) {  // over layers, excluding root
            J = 2**(m-i-1);
            nextIdx = (2**m - 2**(m-i)) + j;
            hashes[nextIdx] = parentHash;

            // want to hash (evenNextIdx, oddNextIdx) where one component equals nextIdx
            parentHash = PoseidonT3.poseidon([hashes[nextIdx-(nextIdx&1)], hashes[nextIdx-(nextIdx&1)+1]]);
            j >>= 1;  // level-specific idx is floor(j/2)
        }
        assert((2**m-2**(m-(m-1)))+j == 2**(n+1)-1-1);  // next `nextIdx` should be last idx.
        hashes[2**(n+1)-1-1] = parentHash;
        root = hashes[2**(n+1)-1-1];
        index++;
        return root;
    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {

        // [assignment] verify an inclusion proof and check that the proof root matches current root
        return super.verifyProof(a, b, c, input) && input[0] == root;
    }
}
