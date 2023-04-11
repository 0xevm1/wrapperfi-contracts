import { expect } from "chai";
import { ethers } from "hardhat";
import { CandyWrapper } from "../typechain/contracts/CandyWrapper";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { BigNumber } from "ethers";
import {atob, btoa} from "buffer";

describe("CandyWrapper", function () {
    let CandyWrapperFactory: ethers.ContractFactory;
    let candyWrapper: CandyWrapper;
    let owner: SignerWithAddress;
    let addr1: SignerWithAddress;
    let addr2: SignerWithAddress;
    let addrs: SignerWithAddress[];

    beforeEach(async function () {

        /*let attributes = `0x`;

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

        const solidityBytes = "0x" + ethers.utils.hexConcat(byteArray).substring(2);*/

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

    describe("TokenURI", async function () {
       it( "Mint 1 NFT & Display Unrevealed URI and then Revealed Uri", async function () {
           let quantity: number = 1;
           const amount: BigNumber = ethers.utils.parseEther((1 * quantity).toString());

            await candyWrapper.mint(1, {value: amount}).then();

            //check that it is minted
            let balance: BigNumber = await candyWrapper.balanceOf(owner.address);
            //console.log("minter balance: ", balance);
            await expect(balance).to.equal(BigNumber.from(quantity));

            //get uri
           let unrevealedURI: string = await candyWrapper.tokenURI(0);
            //console.log("Pre-reveal: ", unrevealedURI);

            //use withdraw money function to reveal
            await candyWrapper.withdrawMoney(owner.address);

            let postRevealURI: string = await candyWrapper.tokenURI(0);
           //console.log("Post-reveal: ", postRevealURI);

           expect(unrevealedURI).to.not.equal(postRevealURI);

           //expect tokenId 1 to fail
           await expect(candyWrapper.tokenURI(1)).to.be.revertedWith("No Candy.");
        });

        it("Mint 5 SVGs", async function () {
            let quantity: number = 5;
            const amount: BigNumber = ethers.utils.parseEther((1 * quantity).toString());

            await candyWrapper.mint(quantity, {value: amount});

            let balance: BigNumber = await candyWrapper.balanceOf(owner.address);

            await expect(balance).to.equal(BigNumber.from(quantity));

            await candyWrapper.withdrawMoney(owner.address);

            console.log("Post-reveal: ", await candyWrapper.tokenURI(1));
            console.log("Post-reveal: ", await candyWrapper.tokenURI(2));
            console.log("Post-reveal: ", await candyWrapper.tokenURI(3));
            console.log("Post-reveal: ", await candyWrapper.tokenURI(4));
        });

    });


});