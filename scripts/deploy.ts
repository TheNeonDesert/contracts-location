import { ethers } from "hardhat";

async function main() {
  // if (process.env.RESOURCE_TOKEN_ADDRESS) {
  const Wilderness = await ethers.getContractFactory("Wilderness");
  const wilderness = await Wilderness.deploy();

  await wilderness.deployed();

  // add Wilderness to minter_role on resource_token
  // wilderness.address

  console.log("Wilderness deployed to:", wilderness.address);
  // } else {
  //   console.log("RESOURCE_TOKEN_ADDRESS is not set in .env file");
  // }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
