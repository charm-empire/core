import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { ethers } from "hardhat";
import { CharmERC20, ERC20Sale } from "../typechain-types";

const deploy_function: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();

  const CharmERC20 = await ethers.getContract<CharmERC20>("CharmERC20");

  await deploy("ERC20Sale", {
    contract: "ERC20Sale",
    from: deployer,
    log: true,
    proxy: {
      proxyContract: "OpenZeppelinTransparentProxy",
      execute: {
        init: {
          args: [0, CharmERC20.address],
          methodName: "initialize",
        },
      },
    },

    skipIfAlreadyDeployed: true,
  });

  const ERC20Sale = await ethers.getContract<ERC20Sale>("ERC20Sale");

  const isAdmin = await CharmERC20.admins(ERC20Sale.address);

  if (!isAdmin) {
    await CharmERC20.updateAdmin(ERC20Sale.address, true);
  }
};

export default deploy_function;

deploy_function.tags = ["ERC20Sale", "development"];
deploy_function.dependencies = ["CharmERC20"];
