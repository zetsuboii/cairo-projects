// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

// For some reason, my editor errors with npm imports, weird
import "../../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../../node_modules/@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "./IStarknetCore.sol";

/// @notice Handles interactions between L1-L2
contract MostarManager is ERC721Holder {
  error UninitializedOnL2();
  
  address public owner;        // Deployer of the contract
  address public initializor;  // Initializes L2 contracts

  IStarknetCore starknetCore;
  // Function IDs for consuming messages
  uint256 constant SEND_BACK = 368166277;
  // Function selectors for sending messages
  uint256 constant INITIALIZE_SELECTOR =
    215307247182100370520050591091822763712463273430149262739280891880522753123;
  uint256 constant REGISTER_SELECTOR =
    453167574301948615256927179001098538682611778866623857597439531518333154691;
  
  // ERC721 address => ERC721m address
  mapping (IERC721 => uint256) public initialized;

  constructor() {
    owner = msg.sender;
    initializor = msg.sender;
    starknetCore = IStarknetCore(0xde29d060D45901Fb19ED6C6e959EB22d8626708e);
  }

  /// @notice Locks ERC721 asset and sends a message to L2
  function send721ToL2(
    ERC721 tokenAddress, 
    uint256 l2UserAddress, 
    uint256 tokenId
  ) external {
    if (initialized[tokenAddress] == 0) revert UninitializedOnL2();

    // Get user's token, it'll revert if user doesn't hold the asset
    // We're importing ERC721Holder, we don't need safeTransferFrom
    tokenAddress.transferFrom(msg.sender, address(this), tokenId);

    // Convert token URI of token to uint256 array
    uint256[] memory stringArr = _stringToUintArray(
      tokenAddress.tokenURI(tokenId)
    );
    uint256 stringArrLen = stringArr.length;

    // Prepare the payload
    uint256[] memory registerPayload = new uint256[](4 + stringArrLen);
    registerPayload[0] = uint256(uint160(l2UserAddress));   // l2addr
    registerPayload[1] = tokenId % (2**128);                // token_id_low
    registerPayload[2] = tokenId / (2**128);                // token_id_high
    registerPayload[3] = stringArrLen;                       // token_uri_len

    for(uint256 i = 4; i < 4 + stringArrLen; i++) {          // token_uri
      registerPayload[i] = stringArr[ i-4 ];
    }

    // Call L2
    starknetCore.sendMessageToL2(
      initialized[tokenAddress], 
      REGISTER_SELECTOR, 
      registerPayload
    );
  }

  function _stringToUintArray(string memory s) 
    private pure returns (uint256[] memory) {
    bytes memory b = bytes(s);
    uint256 size = b.length;
    uint256[] memory arr = new uint256[]((size/32)+1);

    for (uint256 i = 0; i < size; i++) {
      arr[i/32] <<= 8;
      arr[i/32] += uint256(uint8(b[i]));
    }
    return arr;
  }
}