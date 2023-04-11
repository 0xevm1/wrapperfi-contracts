import { ethers } from 'hardhat';
import { CandyWrapper__factory } from '../typechain';
import {BigNumber} from "ethers";
import {expect} from "chai";

async function main() {
  const [deployer] = await ethers.getSigners();

  const candyWrapper = await new CandyWrapper__factory(deployer).deploy();
  await candyWrapper.deployed();
  console.log(`CandyWrapper deployed at ${candyWrapper.address}`);

    let quantity: number = 5;
    const amount: BigNumber = ethers.utils.parseEther((1 * quantity).toString());

    await candyWrapper.mint(quantity, {value: amount}).then();

    //check that it is minted
    let balance: BigNumber = await candyWrapper.balanceOf(deployer.address);

    //get uri
    //let unrevealedURI: string = await candyWrapper.tokenURI(0);
    //console.log("Pre-reveal: ", unrevealedURI);

    //use withdraw money function to reveal
    await candyWrapper.withdrawMoney(deployer.address);

    let postRevealURI: string = await candyWrapper.tokenURI(0);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
});
