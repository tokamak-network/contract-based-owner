import { ethers } from "hardhat";

async function main() {
  const MultiProposerableTransactionExecutor = await ethers.getContractFactory(
    "MultiProposerableTransactionExecutor"
  );
  const multiProposerableTransactionExecutor =
    await MultiProposerableTransactionExecutor.deploy(
      String(process.env.MULTI_PROPOSERABLE_TRANSACTION_EXECUTOR_OWNER_ADDRESS)
    );

  await multiProposerableTransactionExecutor.deployed();

  console.log(`deployed to ${multiProposerableTransactionExecutor.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
