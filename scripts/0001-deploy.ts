import { ethers } from 'hardhat';
import { CandyWrapper__factory } from '../typechain';
import {BigNumber, BigNumberish} from "ethers";
import {expect} from "chai";

async function main() {
  const [deployer, addr1, addr2, addr3, addr4] = await ethers.getSigners();

  const candyWrapper = await new CandyWrapper__factory(deployer).deploy(5, 200);
  await candyWrapper.deployed();
  console.log(`CandyWrapper deployed at ${candyWrapper.address} by ${deployer.address}`);

  let quantity: number = 5;
  let amount: BigNumber = ethers.utils.parseEther((1 * quantity).toString());

  //await candyWrapper.mint(1, quantity, {value: amount}).then();

  //check that it is minted
  //let balance: BigNumber = await candyWrapper.balanceOf(deployer.address);

  //get uri
  //let unrevealedURI: string = await candyWrapper.tokenURI(0);
  //console.log("Pre-reveal: ", unrevealedURI);

  //use withdraw money function to reveal
  //await candyWrapper.withdrawMoney(deployer.address);

  //let postRevealURI: string = await candyWrapper.tokenURI(0);

  quantity = 200;

  await candyWrapper.devMint(quantity);
  console.log(`Balance of ${await deployer.address} is ${await candyWrapper.balanceOf(deployer.address)}`);
  //await candyWrapper.revealCandy();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
});
