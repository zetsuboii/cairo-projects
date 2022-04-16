import * as dotenv from "dotenv";

import { HardhatUserConfig, task } from "hardhat/config";
import "@shardlabs/starknet-hardhat-plugin";

dotenv.config();

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.13"
  },
  starknet: {
    venv: "/home/zet/znity/cairo/cairo_venv/",
  },
  networks: {
    local: {
      url: "http://localhost:5000"
    }
  },
  mocha: {
    timeout: 120000
  }
};

export default config;
