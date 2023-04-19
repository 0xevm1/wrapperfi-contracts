## Wrapper Fi Contracts

The core of the wrapperfi infrastructure.

The NFT collection is completely onchain and interactive using SVGs.

<img width="400" height="400" src="https://raw.githubusercontent.com/0xevm1/wrapperfi-contracts/fd5bcd846965d070c2042d7d4656361810323b54/contracts/CandyWrapper-basevectors.svg">

`npx hardhat compile`

~~Compiling CandyWrapper.sol requires the yulDetails: { optimizerSteps: "u" },setting enabled in hardhat.config.ts, otherwise the normal solidity compiler will return Stack Too Deep.~~

Requires viaIR: true

TODO:

- [x] maybe a switch from vector mode to raster mode, for an individual tokenID

- [x] daoRegistery map, settable by onlyOwner. imports and updates how many referrals have been accomplished.

- [x] dutch auction contracts, and reserved whitelist at half of initial dutch auction price

- [x] do deployment scripts

- [x] do test deployment scripts in hardhat

- [x] ~~add events~~ and check for existing ones in the imports

- [x] '"image": "', true ? super.tokenURI(tokenId) :  make toggle

- [x] configure Candy struct related to auction and increased authorization, put baseUri in there
