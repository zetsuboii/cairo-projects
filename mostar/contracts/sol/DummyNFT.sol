// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "../../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract DummyNFT is ERC721 {
  constructor() ERC721("Dummy NFT", "DNFT") {}
}