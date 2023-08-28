import { deployments, getNamedAccounts, getUnnamedAccounts } from "hardhat";
import { setupUser, setupUsers } from "./utils";
import { CharmERC20, ERC20Sale } from "../../typechain-types";

export const charm_fixture = deployments.createFixture(async (hre) => {
  await hre.deployments.fixture(["development"]);
  const { deployer } = await getNamedAccounts();
  const CharmERC20 = await hre.ethers.getContract<CharmERC20>("CharmERC20");
  const ERC20Sale = await hre.ethers.getContract<ERC20Sale>("ERC20Sale");

  const users = await getUnnamedAccounts();

  const contracts = { CharmERC20, ERC20Sale };

  return {
    ...contracts,
    deployer: await setupUser(deployer, contracts),
    users: await setupUsers(users, contracts),
  };
});
