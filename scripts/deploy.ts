import { ethers } from "hardhat";

async function main() {
  const MultiSigWallet = await ethers.getContractFactory("MultiSigWallet");
  const multiSigWallet = await MultiSigWallet.deploy(String(process.env.MULTI_PROPOSERABLE_TRANSACTION_EXECUTOR_OWNER_ADDRESS));

  await multiSigWallet.deployed();

  console.log(
    `deployed to ${multiSigWallet.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
