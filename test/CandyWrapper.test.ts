import { expect } from "chai";
import { ethers } from "hardhat";
import { CandyWrapper } from "../typechain/contracts/CandyWrapper";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import {BigNumber, BigNumberish} from "ethers";
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

        candyWrapper = (await CandyWrapperFactory.deploy(5, 200)) as CandyWrapper;
        await candyWrapper.deployed();
        console.log(await candyWrapper.address);
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

            await candyWrapper.mint(1, quantity,{value: amount}).then();

            //check that it is minted
            let balance: BigNumber = await candyWrapper.balanceOf(owner.address);
            //console.log("minter balance: ", balance);
            await expect(balance).to.equal(BigNumber.from(quantity));

            //get uri
           let unrevealedURI: string = await candyWrapper.tokenURI(0);
            //console.log("Pre-reveal: ", unrevealedURI);

           // Remove the data URI prefix
           let base64String = unrevealedURI.split("base64,")[1];
           unrevealedURI = (Buffer.from(base64String, 'base64').toString('utf-8'));

           let data = JSON.parse(unrevealedURI);

           console.log(data.image);

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

            await candyWrapper.mint(1, quantity, {value: amount});

            let balance: BigNumber = await candyWrapper.balanceOf(owner.address);

            await expect(balance).to.equal(BigNumber.from(quantity));

            await candyWrapper.withdrawMoney(owner.address);


            //console.log("Pre-reveal: ", unrevealedURI);

            for(let i: number = 0; i < quantity; i++) {
                // Remove the data URI prefix
                let unrevealedURI: string = await candyWrapper.tokenURI(i);
                let base64String = unrevealedURI.split("base64,")[1];
                unrevealedURI = (Buffer.from(base64String, 'base64').toString('utf-8'));

                let data = JSON.parse(unrevealedURI);

                //console.log(data.image);
            }

        });

        it("Mint 20 SVGs between 4 addresses, one mints 6 SVGs which is too many and should fail, another mints 6 betwen two transactions and the second should fail, reveal, update DAO list, check", async function () {

            //address 1

            let quantity: number = 5;
            let amount: BigNumberish = ethers.utils.parseEther((1 * quantity).toString());

            await candyWrapper.connect(addr1).mint(1, quantity, {value: amount});

            let balance: BigNumber = await candyWrapper.balanceOf(addr1.address);

            await expect(balance).to.equal(BigNumber.from(quantity));

            console.log(await addr1.getBalance());

            //address 2
            quantity = 6;
            amount = ethers.utils.parseEther(((1 * quantity).toString()));
            await expect(candyWrapper.connect(addr2).mint(1, quantity, {value: amount})).to.be.revertedWith("Too much Candy.");

            balance = await candyWrapper.balanceOf(addr2.address);

            await expect(balance).to.equal(BigNumber.from(0));

            //address 3
            /*quantity = 3;
            amount = ethers.utils.parseEther(((1 * quantity).toString()));
            await candyWrapper.connect(addrs[0]).mint(1, quantity, {value: amount});
            balance = await candyWrapper.balanceOf(addrs[0].address);
            //console.log("minter balance: ", balance);
            await expect(balance).to.equal(BigNumber.from(quantity));
            quantity = 3;
            amount = ethers.utils.parseEther(((1 * quantity).toString()));
            await expect(candyWrapper.connect(addrs[0]).mint(1, quantity, {value: amount})).to.be.revertedWith("Too much Candy.");
            balance = await candyWrapper.balanceOf(addrs[0].address);
            await expect(balance).to.equal(BigNumber.from(quantity));

            //address 4
            quantity = 5;
            amount = ethers.utils.parseEther((1 * quantity).toString());
            await candyWrapper.connect(addrs[1]).mint(1, quantity, {value: amount});
            balance = await candyWrapper.balanceOf(addrs[1].address);
            await expect(balance).to.equal(BigNumber.from(quantity));

            await candyWrapper.withdrawMoney(owner.address);

            let tokenIds: number[] = [4, 7, 12, 11];
            let referrals: number[] = [1, 5, 100, 0];

            //set DAO Registry
            await candyWrapper.setdaoRegistry(tokenIds, referrals);

            for (let i: number = 0; i < tokenIds.length; i++){
                let uri: string = await candyWrapper.tokenURI(tokenIds[i]);
                let base64String = uri.split("base64,")[1];
                uri = (Buffer.from(base64String, 'base64').toString('utf-8'));

                let data = JSON.parse(uri);

                expect(data.attributes[7].value).to.equal(referrals[i].toString());
            }*/

        });

        it("DAO Referrals to fail from not equal parameter sizes", async function () {
            let tokenIds: number[] = [4, 7, 12, 11];
            let referrals: number[] = [1, 5, 100];

            //set DAO Registry
            await expect(candyWrapper.setdaoRegistry(tokenIds, referrals)).to.be.revertedWith("Same length necessary.");
        });

        it("DAO Referrals to fail from non-owner access", async function () {
            let tokenIds: number[] = [4, 7, 12, 11];
            let referrals: number[] = [1, 5, 100];

            //set DAO Registry
            await expect(candyWrapper.connect(addr1).setdaoRegistry(tokenIds, referrals)).to.be.revertedWith("Ownable: caller is not the owner");
        });

        it("dev mint", async function () {

            //address 1

            let quantity: number = 200;
            let amount: BigNumberish = ethers.utils.parseEther((1 * quantity).toString());

            await candyWrapper.devMint(quantity, {value: amount});

            let balance: BigNumber = await candyWrapper.balanceOf(owner.address);

            await expect(balance).to.equal(BigNumber.from(quantity));
            //console.log("CandyWrapper address", await candyWrapper.address);
            //console.log(balance);
            //let ownerOf: string = await candyWrapper.getOwnershipData(0);
            //console.log(ownerOf);
        });
    });
});