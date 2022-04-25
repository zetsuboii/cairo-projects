// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "openzeppelin/token/ERC721/ERC721.sol";
import "openzeppelin/access/Ownable.sol";
import "openzeppelin/utils/Counters.sol";

contract DummyNFT is ERC721, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("DummyNFT", "DNFT") {}

    function _baseURI() internal pure override returns (string memory) {
        return "https://live---metadata-5covpqijaa-uc.a.run.app/metadata/";
    }

    function safeMint(address to) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }
}