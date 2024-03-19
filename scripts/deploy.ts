import { ethers } from "hardhat";

async function main() {
  if (
    process.env.RESOURCE_TOKEN_ADDRESS &&
    process.env.AVATAR_ADDRESS &&
    process.env.STICK_ID &&
    process.env.STONE_ID &&
    process.env.PLANTFIBER_ID &&
    process.env.APPLE_ID
  ) {
    console.log("Deploying Wilderness... contract-location");
    // const Wilderness = await ethers.getContractFactory("Wilderness");
    const wilderness = await ethers.deployContract("Wilderness", [
      process.env.AVATAR_ADDRESS,
      process.env.RESOURCE_TOKEN_ADDRESS,
      process.env.STICK_ID,
      process.env.STONE_ID,
      process.env.PLANTFIBER_ID,
      process.env.APPLE_ID,
    ]);

    await wilderness.waitForDeployment();

    console.log("Wilderness deployed to:", wilderness.target);
  } else {
    console.log(
      "Must set RESOURCE_TOKEN_ADDRESS AVATAR_ADDRESS STICK_ID STONE_ID PLANTFIBER_ID APPLE_ID in .env file"
    );
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
