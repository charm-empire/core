import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const deploy_function: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();

  await deploy("CharmERC20", {
    contract: "CharmERC20",
    from: deployer,
    log: true,
    proxy: {
      proxyContract: "OpenZeppelinTransparentProxy",
      execute: {
        init: {
          args: ["Charm", "$CHARM"],
          methodName: "initialize",
        },
      },
    },

    skipIfAlreadyDeployed: true,
  });
};

export default deploy_function;

deploy_function.tags = ["CharmERC20", "development"];
