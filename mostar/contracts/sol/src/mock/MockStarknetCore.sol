// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "../IStarknetCore.sol";

contract MockStarknetCore is IStarknetCore {
  event ConsumeMsg(uint256 fromAddress, uint256[] payload);
  event SendMsg(uint256 toAddress, uint256 selector, uint256[] payload);

  function consumeMessageFromL2(uint256 fromAddress, uint256[] memory payload) external returns(bytes32) {
    emit ConsumeMsg(fromAddress, payload);
    return 0x0;
  }

  function sendMessageToL2(
    uint256 toAddress,
    uint256 selector,
    uint256[] calldata payload
  ) external returns (bytes32) {
    emit SendMsg(toAddress, selector, payload);
    return 0x0;
  }
}