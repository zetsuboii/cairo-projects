// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

// For some reason, my editor errors with npm imports, weird
import "../../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../../node_modules/@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "./IStarknetCore.sol";

/// @notice Handles interactions between L1-L2
contract Mostar is ERC721Holder {
  error NotOwner();
  error ZeroAddress();
  error NotInitializer();
  error UninitializedOnL2();
  error AlreadyInitialized();
  
  address public owner;        // Deployer of the contract
  address public initializer;  // Initializes L2 contracts

  IStarknetCore starknetCore;
  // Function IDs for consuming messages
  uint256 constant SEND_BACK = 368166277;
  // Function selectors for sending messages
  uint256 constant INITIALIZE_SELECTOR =
    215307247182100370520050591091822763712463273430149262739280891880522753123;
  uint256 constant REGISTER_SELECTOR =
    453167574301948615256927179001098538682611778866623857597439531518333154691;
  
  // ERC721 address => ERC721m address
  mapping (IERC721 => uint256) public initialized721;
  // ERC721 address => tokenId => old owner
  mapping (IERC721 => mapping(uint256 => address)) public owners721;

  constructor() {
    owner = msg.sender;
    initializer = msg.sender;
    starknetCore = IStarknetCore(0xde29d060D45901Fb19ED6C6e959EB22d8626708e);
  }

  modifier onlyOwner {
    if (msg.sender != owner) revert NotOwner();
    _;
  }

  modifier onlyInitializer {
    if (msg.sender != initializer) revert NotInitializer();
    _;
  }

  /// @notice Sets new initializer, only owner can call it
<<<<<<< HEAD
  function setInitializer(address newInitializer) external onlyOwner {
=======
  function setInitializor(address newInitializer) external onlyOwner {
>>>>>>> 33e132a5ebbda7a300977d6c1e1c1eb979051987
    if (newInitializer == address(0)) revert ZeroAddress();
    initializer = newInitializer;
  }

  /// @notice Save L2 ERC721m address for a ERC721 token, manager only
  /// @param tokenAddress    ERC721 asset's address
  /// @param l2TokenAddress  Starknet address of token
  /// @dev @pre: Token address exists on Starknet
  function initialize721(
    ERC721 tokenAddress, 
    uint256 l2TokenAddress
  ) external onlyInitializer{
    if(initialized721[tokenAddress] != 0) revert AlreadyInitialized();

    // Initialize token address
    initialized721[tokenAddress] = l2TokenAddress;

    // POSSIBLE FEATURE: Append Mostar to name and .M to the symbol
    uint256[] memory initPayload = new uint256[](3);
    initPayload[0] = _stringToUint(tokenAddress.name());
    initPayload[1] = _stringToUint(tokenAddress.symbol());
    initPayload[2] = uint256(uint160(address(this)));

    // Call L2 so that contract is initialized
    starknetCore.sendMessageToL2(
      l2TokenAddress, 
      INITIALIZE_SELECTOR, 
      initPayload
    );
  }

  /// @notice Locks ERC721 asset and sends a message to L2
  /// @param tokenAddress   ERC721 asset's address
  /// @param l2UserAddress  Starknet address of user
  /// @param tokenId        ID of the token
  function send721ToL2(
    ERC721 tokenAddress, 
    uint256 l2UserAddress, 
    uint256 tokenId
  ) external {
    if (initialized721[tokenAddress] == 0) revert UninitializedOnL2();

    // Get user's token, it'll revert if user doesn't hold the asset
    // We're importing ERC721Holder, we don't need safeTransferFrom
    tokenAddress.transferFrom(msg.sender, address(this), tokenId);
    
    // We'll need owner's information later in retrieve721
    owners721[tokenAddress][tokenId] = msg.sender;

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
      initialized721[tokenAddress], 
      REGISTER_SELECTOR, 
      registerPayload
    );
  }

  /// @notice Retrieves the locked NFT that is sent back from L2
  /// @param tokenAddress   ERC721 asset's address
  /// @param tokenId        ID of the token
  function retrieve721(ERC721 tokenAddress, uint256 tokenId) external {
    if(tokenAddress.ownerOf(tokenId) == msg.sender) revert NotOwner();
    if (initialized721[tokenAddress] == 0) revert UninitializedOnL2();

    uint256[] memory rcvPayload = new uint256[](4);
    rcvPayload[0] = SEND_BACK;
    rcvPayload[1] = uint256(uint160(address(tokenAddress))); // solidity.
    rcvPayload[2] = tokenId % (2**128);
    rcvPayload[3] = tokenId / (2**128);

    starknetCore.consumeMessageFromL2(initialized721[tokenAddress], rcvPayload);

    // If above call didn't revert it means there was really a message that
    // sent the asset back, in that case transfer NFT back to the owner
    tokenAddress.transferFrom(address(this), msg.sender, tokenId);
  }

  /// @notice Converts ASCII string to uint256 array
  function _stringToUintArray(string memory s) 
    private pure returns (uint256[] memory) {
    bytes memory b = bytes(s);

    uint256 size = b.length;
    uint256[] memory arr = new uint256[]((size/32)+1);
    for (uint256 i = 0; i < size; ++i) {
      arr[i/32] <<= 8;
      arr[i/32] += uint256(uint8(b[i]));
    }
    return arr;
  }

  /// @notice Converts ASCII string to uint256, given its length is lt 32
  function _stringToUint(string memory s) 
    private pure returns (uint256) {
    bytes memory b = bytes(s);

    uint256 size = b.length;
    uint256 sum;
    for (uint256 i = 0; i < size; ++i) {
      sum <<= 8;
      sum += uint256(uint8(b[i]));
    }
    return sum;
  }
}