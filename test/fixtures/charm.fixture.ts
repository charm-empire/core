import { deployments, getNamedAccounts, getUnnamedAccounts } from "hardhat";
import { setupUser, setupUsers } from "./utils";
import { CharmERC20 } from "../../typechain-types";

export const charm_fixture = deployments.createFixture(async (hre) => {
  await hre.deployments.fixture(["CharmERC20"]);
  const { deployer } = await getNamedAccounts();
  const CharmERC20 = await hre.ethers.getContract<CharmERC20>("CharmERC20");

  const users = await getUnnamedAccounts();

  const contracts = { CharmERC20 };

  return {
    ...contracts,
    deployer: await setupUser(deployer, contracts),
    users: await setupUsers(users, contracts),
  };
});
