import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { ethers } from "hardhat";

const deploy_function: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();

  const charmERC20 = await deployments.get("CharmERC20");

  await deploy("CharmERC721", {
    contract: "CharmERC721",
    from: deployer,
    log: true,
    proxy: {
      proxyContract: "OpenZeppelinTransparentProxy",
      execute: {
        init: {
          args: ["CharmNFT", "CHARM NFT", "", charmERC20.address],
          methodName: "initialize",
        },
      },
    },

    skipIfAlreadyDeployed: true,
  });
};

export default deploy_function;

deploy_function.tags = ["CharmERC721", "development"];
deploy_function.dependencies = ["CharmERC20"];
