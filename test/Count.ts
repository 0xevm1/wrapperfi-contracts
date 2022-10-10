import { expect } from 'chai';
import {WrapperFi, WrapperFi__factory} from '../typechain';
import { ethers } from 'hardhat';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/dist/src/signer-with-address';

let deployer: SignerWithAddress;
let wrap: WrapperFi;

describe('WrapperFi', () => {
  let snapshotId: number;

  before(async () => {
    [deployer] = await ethers.getSigners();

    wrap = await new WrapperFi__factory(deployer).deploy();
  });

  beforeEach(async () => {
    snapshotId = await ethers.provider.send('evm_snapshot', []);
  });

  afterEach(async () => {
    await ethers.provider.send('evm_revert', [snapshotId]);
  });

  /*describe('#increment', () => {
    it('should properly increment count', async () => {
      expect(await count.count()).to.eq(0);
      await count.increment();
      expect(await count.count()).to.eq(1);
      await count.increment();
      await count.increment();
      expect(await count.count()).to.eq(3);
    });
  });*/
});
