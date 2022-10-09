import { ethers } from 'hardhat';
import { Count__factory } from '../typechain';

async function main() {
  const [deployer] = await ethers.getSigners();

  const count = await new Count__factory(deployer).deploy();
  await count.deployed();
  console.log(`Count deployed at ${count.address}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
