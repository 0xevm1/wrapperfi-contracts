## Wrapper Fi Contracts

The core of the wrapperfi infrastructure.

The NFT collection is completely onchain and interactive using SVGs. Incorporated bitpacking for random attributes that aren't known in advance, but prepared in the deployment script and constructor.

<img width="400" height="400" src="https://raw.githubusercontent.com/Wrapper-Fi/wrapperfi-contracts/a7c56a4ba92d583fa5d7f0d9b13f6a6ae9e409e1/contracts/CandyWrapper-basevectors.svg">

`npx hardhat compile`

Compiling CandyWrapper.sol requires the yulDetails: { optimizerSteps: "u" },setting enabled in hardhat.config.ts, otherwise the normal solidity compiler will return Stack Too Deep. Does not require viaIR: true despite the hardhat/solidity compiler suggesting that solution

TODO:

- [x] maybe a switch from vector mode to raster mode, for an individual tokenID

- [x] daoRegistery map, settable by onlyOwner. imports and updates how many referrals have been accomplished.

- [ ] dutch auction contracts, and reserved whitelist at half of initial dutch auction price

- [ ] do deployment scripts

- [ ] add events and check for existing ones in the imports

- [x] '"image": "', true ? super.tokenURI(tokenId) :  make toggle

- [x] configure Candy struct related to auction and increased authorization, put baseUri in there