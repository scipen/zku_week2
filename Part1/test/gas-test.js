const { poseidonContract, mimcSpongecontract } = require("circomlibjs");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("GasTest", function () {
    let gasTest;

    beforeEach(async function () {

        const PoseidonT3 = await ethers.getContractFactory(
            poseidonContract.generateABI(2),
            poseidonContract.createCode(2)
        )
        const poseidonT3 = await PoseidonT3.deploy();
        await poseidonT3.deployed();

        const MimcSponge = await ethers.getContractFactory(
            mimcSpongecontract.abi,
            mimcSpongecontract.createCode("mimcsponge", 220)
        )
        const mimcSponge = await MimcSponge.deploy();
        await mimcSponge.deployed();

        const GasTest = await ethers.getContractFactory("GasTest", {
            libraries: {
                PoseidonT3: poseidonT3.address,
                MimcSponge: mimcSponge.address
            },
          });
        gasTest = await GasTest.deploy();
        await gasTest.deployed();
    });

    it("test poseidon", async function () {
        const estimation = await gasTest.estimateGas.testPoseidon();
        console.log(estimation);
        expect(true).to.be.true;
    });

    it("test mimc", async function () {
        const estimation = await gasTest.estimateGas.testMimc();
        console.log(estimation);
        expect(true).to.be.true;
    });
});
