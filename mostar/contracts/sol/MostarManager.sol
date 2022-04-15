// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import { IStarknetCore } from "./IStarknetCore.sol";

/// @notice Handles interactions between L1-L2
contract MostarManager {
  
  IStarknetCore starknetCore;
  // Function IDs for consuming messages
  uint256 constant SEND_BACK = 368166277;
  // Function selectors for sending messages
  uint256 constant INITIALIZE_SELECTOR =
    215307247182100370520050591091822763712463273430149262739280891880522753123;
  uint256 constant REGISTER_SELECTOR =
    453167574301948615256927179001098538682611778866623857597439531518333154691;
  
  constructor() {
    starknetCore = IStarknetCore(0xde29d060D45901Fb19ED6C6e959EB22d8626708e);
  }
}