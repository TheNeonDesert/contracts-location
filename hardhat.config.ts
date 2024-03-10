import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.24",
  networks: {
    hardhat: {
      // Configuration specific to the Hardhat network
      chainId: 1337, // Default chain ID for Hardhat network
      // You can specify additional Hardhat network config here
    },
    // Define other networks here as needed
  },
};

export default config;
