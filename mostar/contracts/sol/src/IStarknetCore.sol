// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IStarknetCore {
  /// @notice Sends a message to an L2 contract.
  /// @return the hash of the message.
  function sendMessageToL2(
    uint256 toAddress,
    uint256 selector,
    uint256[] calldata payload
  ) external returns (bytes32);

  /// @notice Consumes a message that was sent from an L2 contract.
  /// @return the hash of the message.
  function consumeMessageFromL2(uint256 fromAddress, uint256[] calldata payload)
    external returns(bytes32);
}