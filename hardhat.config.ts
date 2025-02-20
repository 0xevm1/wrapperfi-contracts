import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import dotenv from "dotenv";
import "hardhat-abi-exporter";
import "hardhat-contract-sizer";
import "hardhat-gas-reporter";
import "@primitivefi/hardhat-dodoc";
import { HardhatUserConfig } from "hardhat/config";
import { NetworkUserConfig } from "hardhat/types";
import 'hardhat-tracer';
import {utils} from "ethers";

dotenv.config();

const chainIds = {
  hardhat: 31337,
  ganache: 1337,
  mainnet: 1,
  ropsten: 3,
  rinkeby: 4,
  goerli: 5,
  kovan: 42,
  avax: 43114,
  avax_testnet: 43113,
  fantom: 250,
  fantom_testnet: 4002,
  polygon: 137,
  mumbai: 80001,
  optimism: 10,
  optimism_kovan: 69,
  optimism_goerli: 420,
  arbitrum: 42161,
  arbitrum_rinkeby: 421611,
  arbitrum_goerli: 421613,
  binance: 56,
  binance_testnet: 97,
  ethw: 10001,
  ethw_iceberg_testnet: 10002,
  zksync_era: 324,
  zksync_era_testnet: 280
};

// Ensure that we have all the environment variables we need.
const testPrivateKey: string = process.env.TEST_PRIVATE_KEY || "";
const alchemyKey: string = process.env.ALCHEMY_KEY || "";
const explorerScanKey: string = process.env.SCAN_API_KEY || "";

function createTestnetConfig(network: keyof typeof chainIds): NetworkUserConfig {
  if (!alchemyKey) {
    throw new Error("Missing ALCHEMY_KEY");
  }

  const polygonNetworkName = network === "polygon" ? "mainnet" : "mumbai";

  let nodeUrl =
    chainIds[network] == 137 || chainIds[network] == 80001
      ? `https://polygon-${polygonNetworkName}.g.alchemy.com/v2/${alchemyKey}`
      : `https://eth-${network}.alchemyapi.io/v2/${alchemyKey}`;

  switch (network) {
    case "mainnet":
      nodeUrl = `https://eth-mainnet.g.alchemy.com/v2/${alchemyKey}`;
    case "goerli":
      nodeUrl = `https://eth-goerli.g.alchemy.com/v2/${alchemyKey}`;
      break;
    case "optimism":
      nodeUrl = `https://opt-mainnet.g.alchemy.com/v2/${alchemyKey}`;
      break;
    case "optimism_kovan":
      nodeUrl = `https://opt-kovan.g.alchemy.com/v2/${alchemyKey}`;
      break;
    case "optimism_goerli":
      nodeUrl = `https://opt-goerli.g.alchemy.com/v2/${alchemyKey}`;
      break;
    case "arbitrum":
      nodeUrl = `https://arb-mainnet.g.alchemy.com/v2/${alchemyKey}`;
      break;
    case "arbitrum_rinkeby":
      nodeUrl = `https://arb-rinkeby.g.alchemy.com/v2/${alchemyKey}`;
      break;
    case "arbitrum_goerli":
      nodeUrl = `https://arb-goerli.g.alchemy.com/v2/${alchemyKey}`;
      break;
    case "avax":
      nodeUrl = "https://api.avax.network/ext/bc/C/rpc";
      break;
    case "avax_testnet":
      nodeUrl = "https://api.avax-test.network/ext/bc/C/rpc";
      break;
    case "fantom":
      nodeUrl = "https://rpc.ftm.tools";
      break;
    case "fantom_testnet":
      nodeUrl = "https://rpc.testnet.fantom.network";
      break;
    case "binance":
      nodeUrl = "https://bsc-dataseed1.binance.org/";
      break;
    case "binance_testnet":
      nodeUrl = "https://data-seed-prebsc-1-s1.binance.org:8545/";
      break;
    case "ethw":
      nodeUrl = "https://mainnet.ethereumpow.org";
      break;
    case "ethw_iceberg_testnet":
      nodeUrl = "https://iceberg.ethereumpow.org";
      break;
    case "zksync_era":
      nodeUrl = "https://mainnet.era.zksync.io";
      break;
    case "zksync_era_testnet":
      nodeUrl = "https://testnet.era.zksync.dev";
      break;
  }

  return {
    chainId: chainIds[network],
    url: nodeUrl,
    accounts: [`${testPrivateKey}`],
  };
}

const config: HardhatUserConfig = {
  paths: {
    artifacts: "./artifacts",
    cache: "./cache",
    sources: "./contracts",
    tests: "./test",
  },
  solidity: {
    version: "0.8.18",
    settings: {
      viaIR: true,
      metadata: {
        bytecodeHash: "ipfs",
      },
      // You should disable the optimizer when debugging
      // https://hardhat.org/hardhat-network/#solidity-optimizer-support
      optimizer: {
        enabled: true,
        runs: 1
      },
    },
  },
  abiExporter: {
    flat: true,
  },
  typechain: {
    outDir: "typechain",
    target: "ethers-v5",
  },
  etherscan: {
    apiKey: {
      mainnet: process.env.ETHERSCAN_API_KEY || process.env.SCAN_API_KEY,
      ropsten: process.env.ETHERSCAN_API_KEY || process.env.SCAN_API_KEY,
      rinkeby: process.env.ETHERSCAN_API_KEY || process.env.SCAN_API_KEY,
      goerli: process.env.ETHERSCAN_API_KEY || process.env.SCAN_API_KEY,
      kovan: process.env.ETHERSCAN_API_KEY || process.env.SCAN_API_KEY,
      polygon: process.env.POLYGONSCAN_API_KEY || process.env.SCAN_API_KEY,
      polygonMumbai: process.env.POLYGONSCAN_API_KEY || process.env.SCAN_API_KEY,
      opera: process.env.FANTOMSCAN_API_KEY || process.env.SCAN_API_KEY,
      ftmTestnet: process.env.FANTOMSCAN_API_KEY || process.env.SCAN_API_KEY,
      avalanche: process.env.SNOWTRACE_API_KEY || process.env.SCAN_API_KEY,
      avalancheFujiTestnet: process.env.SNOWTRACE_API_KEY || process.env.SCAN_API_KEY,
      optimisticEthereum: process.env.OPTIMISM_SCAN_API_KEY || process.env.SCAN_API_KEY,
      optimisticKovan: process.env.OPTIMISM_SCAN_API_KEY || process.env.SCAN_API_KEY,
      arbitrumOne: process.env.ARBITRUM_SCAN_API_KEY || process.env.SCAN_API_KEY,
      arbitrumTestnet: process.env.ARBITRUM_SCAN_API_KEY || process.env.SCAN_API_KEY,
      bsc: process.env.BINANCE_SCAN_API_KEY || process.env.SCAN_API_KEY,
      bscTestnet: process.env.BINANCE_SCAN_API_KEY || process.env.SCAN_API_KEY,
    },
  },
  gasReporter: {
    currency: "USD",
    enabled: true //process.env.REPORT_GAS ? true : false,
  },
  dodoc: {
    runOnCompile: true,
    exclude: ["**/node_modules/**"],
    keepFileStructure: false,
  },
  contractSizer: {
    alphaSort: true,
    disambiguatePaths: false,
    runOnCompile: true,
    strict: true,
  }
};

if (testPrivateKey) {
  config.networks = {
    mainnet: createTestnetConfig("mainnet"),
    goerli: createTestnetConfig("goerli"),
    rinkeby: createTestnetConfig("rinkeby"),
    polygon: createTestnetConfig("polygon"),
    mumbai: createTestnetConfig("mumbai"),
    fantom: createTestnetConfig("fantom"),
    fantom_testnet: createTestnetConfig("fantom_testnet"),
    avax: createTestnetConfig("avax"),
    avax_testnet: createTestnetConfig("avax_testnet"),
    arbitrum: createTestnetConfig("arbitrum"),
    arbitrum_rinkeby: createTestnetConfig("arbitrum_rinkeby"),
    arbitrum_goerli: createTestnetConfig("arbitrum_goerli"),
    optimism: createTestnetConfig("optimism"),
    optimism_kovan: createTestnetConfig("optimism_kovan"),
    optimism_goerli: createTestnetConfig("optimism_goerli"),
    binance: createTestnetConfig("binance"),
    binance_testnet: createTestnetConfig("binance_testnet"),
    ethw: createTestnetConfig("ethw"),
    ethw_iceberg_test: createTestnetConfig("ethw_iceberg_testnet"),
    zksync_era: createTestnetConfig("zksync_era"),
    zksync_era_testnet: createTestnetConfig("zksync_era_testnet")
  };
}

config.networks = {
  ...config.networks,
  hardhat: {
    chainId: 1337,
    accounts:
      {
        mnemonic: "test test test test test test test test test test test junk",
        path: "m/44'/60'/0'/0",
        initialIndex: 0,
        count: 20,
        passphrase: "",
      }
  }
};

export default config;
