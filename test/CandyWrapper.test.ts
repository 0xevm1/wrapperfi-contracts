import { expect } from "chai";
import { ethers } from "hardhat";
import { CandyWrapper } from "../typechain/contracts/CandyWrapper";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { BigNumber } from "ethers";

describe("CandyWrapper", function () {
    let CandyWrapperFactory: ethers.ContractFactory;
    let candyWrapper: CandyWrapper;
    let owner: SignerWithAddress;
    let addr1: SignerWithAddress;
    let addr2: SignerWithAddress;
    let addrs: SignerWithAddress[];

    beforeEach(async function () {

        let attributes = `0x`;

        function doubleDecimalToBinary(a: BigNumber, b: BigNumber, offset_a: number): BigNumber {
            let binaryPrimer = '00000000';

            //get binary representation of random number
            let binary_a = a.toNumber().toString(2);

            let binary_b = b.toNumber().toString(2);

            //pad binary representation with leading zeros
            binary_b = binaryPrimer.substring(0, binaryPrimer.length - binary_b.length) + binary_b;

            //cut it down to size
            binary_b = binary_b.substring(offset_a, binary_b.length);

            //combine binary numbers to fit in a single byte && convert back into decimal number
            let binary_c = binary_a + binary_b;

            return BigNumber.from(parseInt(binary_c, 2));
        }

        function getRandomInt(min: number, max: number): number {
            return Math.floor(Math.random() * (max - min + 1)) + min;
        }

        let numAttributes = 1; //32 attributes fit in one storage slot, which is 32 bytes and 256 bits.
        let byteArray: string[] = [];

        for (let i = 0; i < numAttributes; i++) {
            byteArray.push(doubleDecimalToBinary(BigNumber.from(getRandomInt(0, 9)), BigNumber.from(getRandomInt(0, 9)),4).toHexString());
        }

        const solidityBytes = "0x" + ethers.utils.hexConcat(byteArray).substring(2);

        CandyWrapperFactory = await ethers.getContractFactory("CandyWrapper");
        [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

        //configure attributes with the bitpacking as rehearsed

        //it should store 6 indexes as binary and pack each pair into a single bit

        candyWrapper = (await CandyWrapperFactory.deploy()) as CandyWrapper;
        await candyWrapper.deployed();
    });

    describe("Deployment", function () {
        it("Should set the correct token name and symbol", async function () {
            expect(await candyWrapper.name()).to.equal("Candy");
            expect(await candyWrapper.symbol()).to.equal("CANDY");
        });

        /*it("Should return random values by tokenId", async function () {

            let indexA = await candyWrapper.getSixRandomValues(0);
            let indexB = await candyWrapper.getSixRandomValues(1);
            console.log("indexA: ", indexA);
            console.log("indexB: ", indexB);

           expect(indexA).to.not.deep.equal(indexB);
        });*/
    });


});