//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol";
import { MimcSponge } from "./Mimc.sol";

contract GasTest {
    uint private ROUNDS = 100;

    function testPoseidon() public view {
        uint h = 42;
        for (uint i=0; i < ROUNDS; i++) {
            h = PoseidonT3.poseidon([h, h]);
        }
    }

    function testMimc() public view {
        uint xl = 42;
        uint xr = 43;
        for (uint i=0; i < ROUNDS; i++) {
            (xl, xr) = MimcSponge.MiMCSponge(xl, xr, 0);
        }
    }

    function baseline() public pure returns (uint) {
    }
}
