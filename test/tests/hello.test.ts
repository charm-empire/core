import { ethers } from "ethers";
import { charm_fixture } from "../fixtures/charm.fixture";
import { PromiseType } from "../fixtures/utils";
import { expect, use } from "chai";

describe("Charm ERC20 Test", () => {
  type Fixture = PromiseType<ReturnType<typeof charm_fixture>>;
  let deployer: Fixture["deployer"];
  let alice: Fixture["users"][number];
  let bob: Fixture["users"][number];

  beforeEach(async () => {
    ({
      deployer,
      users: [alice, bob],
    } = await charm_fixture());
  });

  it("$CHARM test", async () => {
    const $CHARM = deployer.CharmERC20;
    expect(await $CHARM.name()).to.eq("Charm");

    await expect(
      $CHARM.mint(deployer.address, ethers.utils.parseEther(`${100}`))
    )
      .to.emit($CHARM, "Transfer")
      .withArgs(
        ethers.constants.AddressZero,
        deployer.address,
        ethers.utils.parseEther(`${100}`)
      );
  });

  // // Often, chai emit does not match the event.
  // // This validates the installation of @hardhat/toolbox.
  // // Recommended to leave in at least one such test.
  // it("emit incorrect test", async () => {
  //   let error = false;
  //   try {
  //     const Hello = deployer.Hello;
  //     await expect(Hello.message("Some Message"))
  //       .to.emit(Hello, "MessageEventFail")
  //       .withArgs("Some Message");
  //   } catch (_err) {
  //     error = true;
  //   }
  //   if (error === false) {
  //     throw new Error("Test should have failed");
  //   }
  // });
});
