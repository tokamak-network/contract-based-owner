import { HardhatUserConfig } from "hardhat/config";
import "hardhat-deploy";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from "dotenv";

dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  networks: {
    mainnet: {
      url: "https://rpc.tokamak.network",
      accounts: [`${process.env.PRIVATE_KEY}`],
    },
    goerli: {
      url: "https://goerli.rpc.tokamak.network",
      accounts: [`${process.env.PRIVATE_KEY}`],
    },
    goerli_nightly: {
      url: "https://goerli.rpc.tokamak.network",
      accounts: [`${process.env.PRIVATE_KEY}`],
    },
    titan: {
      url: "https://rpc.titan.tokamak.network",
      accounts: [`${process.env.PRIVATE_KEY}`],
    },
    titan_goerli: {
      url: "https://rpc.titan-goerli.tokamak.network",
      accounts: [`${process.env.PRIVATE_KEY}`],
    },
    titan_goerli_nightly: {
      url: "https://rpc.titan-goerli-nightly.tokamak.network",
      accounts: [`${process.env.PRIVATE_KEY}`],
    }
  },
  etherscan: {
    apiKey: {
      mainnet: String(process.env.ETHERSCAN_API_KEY),
      goerli: String(process.env.ETHERSCAN_API_KEY),
      goerli_nightly: String(process.env.ETHERSCAN_API_KEY),
    },
  },
  paths: {
    deploy: "deploy",
    deployments: "deployments",
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
  },
};

export default config;
