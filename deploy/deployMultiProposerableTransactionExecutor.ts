// TypeScript
import { DeployFunction, DeployResult } from "hardhat-deploy/dist/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

/**
 * * Important Notes
 *
 * * In order to run `npx hardhat deploy --typecheck` command we need to add `import hardhat-deploy` in `hardhat.config.js` file.
 *
 */

const deployMultiProposerableTransactionExecutor: DeployFunction = async (
  hre: HardhatRuntimeEnvironment
) => {
  const { deploy } = hre.deployments;
  const { deployer } = await hre.getNamedAccounts();

  const MultiProposerableTransactionExecutor: DeployResult = await deploy(
    "MultiProposerableTransactionExecutor",
    {
      from: deployer,
      log: true,
      args: [],
      waitConfirmations: 6,
    }
  );

  try {
    console.log("Verifying on Etherscan...");
    await hre.run("verify:verify", {
      address: MultiProposerableTransactionExecutor.address,
      constructorArguments: [],
    });
    console.log("Successfully verified on Etherscan");
  } catch (error) {
    console.log("Error when verifying bytecode on Etherscan:");
    console.log(error);
  }

  try {
    console.log("TransferOwnership...");
    if (!process.env.MULTI_PROPOSERABLE_TRANSACTION_EXECUTOR_OWNER_ADDRESS) {
      console.log("We don't need to execute transferOwnership");
      return;
    }
    const multiProposerableTransactionExecutor = await hre.ethers.getContractAt(
      "MultiProposerableTransactionExecutor",
      MultiProposerableTransactionExecutor.address
    );

    const tx = await multiProposerableTransactionExecutor.transferOwnership(
      String(process.env.MULTI_PROPOSERABLE_TRANSACTION_EXECUTOR_OWNER_ADDRESS)
    );
    await tx.wait();

    console.log("Successfully transferOwnership");
  } catch (error) {
    console.log("Error when executing transferOwnership");
    console.log(error);
  }
};

export default deployMultiProposerableTransactionExecutor;
deployMultiProposerableTransactionExecutor.tags = [
  "multiProposerableTransactionExecutor",
];
