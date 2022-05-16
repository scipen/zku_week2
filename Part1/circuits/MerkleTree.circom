pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/mux1.circom";
include "../node_modules/circomlib/circuits/poseidon.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    
    // convention note: tree with just root has depth 0.
    // in total we must compute 2^n-1 hashes in a tree of depth n with 2^(n+1) nodes.
    // create flattened tree of hashes, bottom to top, starting at level above leaves
    component poseidon[2**n-1];

    for (var i=0; i < n; i++) {  // over levels, starting at level above leaves
        for (var j=0; j < 2**(n-i-1); j++) {  // over nodes within level
            var idx = (2**n - 2**(n-i)) + j;

            poseidon[idx] = Poseidon(2);
            if (i == 0) {  // initial level above leaves
                poseidon[idx].inputs[0] <== leaves[2*idx];
                poseidon[idx].inputs[1] <== leaves[2*idx + 1];
            } else {
                var childLeftIdx = (2**n - 2**(n-(i-1))) + 2*j;
                var childRightIdx = (2**n - 2**(n-(i-1))) + 2*j + 1;
                poseidon[idx].inputs[0] <== poseidon[childLeftIdx].out;
                poseidon[idx].inputs[1] <== poseidon[childRightIdx].out;
            }
        }
    }

    root <== poseidon[2**n-1-1].out;
}


template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    component poseidon[n];
    component mux[n];
    var hash = leaf;

    for (var i=0; i < n; i++) {
        poseidon[i] = Poseidon(2);
        mux[i] = MultiMux1(2);
        mux[i].c[0][0] <== hash;
        mux[i].c[0][1] <== path_elements[i];
        mux[i].c[1][0] <== path_elements[i];
        mux[i].c[1][1] <== hash;
        mux[i].s <== path_index[i];

        poseidon[i].inputs[0] <== mux[i].out[0];
        poseidon[i].inputs[1] <== mux[i].out[1];
        hash = poseidon[i].out;
    }
    root <== hash;
}