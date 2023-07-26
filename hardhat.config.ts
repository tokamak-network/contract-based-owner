import { HardhatUserConfig } from "hardhat/config";
import "hardhat-deploy";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from "dotenv";

dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.18",
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
  },
  etherscan: {
    apiKey: {
      goerli: String(process.env.ETHERSCAN_API_KEY),
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
