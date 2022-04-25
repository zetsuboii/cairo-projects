// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "ds-test/test.sol";
import "./CheatCodes.sol";

import "../Mostar.sol";
import "../mock/MockStarknetCore.sol";
import "../DummyNFT.sol";

contract ContractTest is DSTest {
    address owner;
    address initializer;
    address user1;
    address user2;
    CheatCodes cheats;

    uint256 constant L2TOKEN = 0xdeadbeef;
    uint256 constant L2USER = 0x1337;
    uint256 constant DUMMY_NFT_STR = 4932969283808282196;
    uint256 constant DNFT_STR = 1145980500;

    // TODO: Double check using another language than Solidity
    uint256 constant DNFT_URI_0 = 
      184555836509371486644780171450602921423280935324998648549295426022390395241;
    uint256 constant DNFT_URI_1 = 
      43762353752813685829269877461283290467173731243990994689208692528;

    // Function IDs for consuming messages
    uint256 constant SEND_BACK = 368166277;
    // Function selectors for sending messages
    uint256 constant INITIALIZE_SELECTOR =
      215307247182100370520050591091822763712463273430149262739280891880522753123;
    uint256 constant REGISTER_SELECTOR =
      453167574301948615256927179001098538682611778866623857597439531518333154691;

    // Events that we'll test against
    event ConsumeMsg(uint256 fromAddress, uint256[] payload);
    event SendMsg(uint256 toAddress, uint256 selector, uint256[] payload);

    DummyNFT nft;
    MockStarknetCore starknet;
    Mostar mostar;
    
    function setUp() public {
      cheats = CheatCodes(HEVM_ADDRESS);
      
      owner = cheats.addr(10);
      initializer = cheats.addr(20);
      user1 = cheats.addr(30);
      user2 = cheats.addr(40);

      cheats.startPrank(owner);
      nft = new DummyNFT();
      starknet = new MockStarknetCore();
      mostar = new Mostar(starknet);
      nft.safeMint(user1);
      cheats.stopPrank();

      cheats.startPrank(user1);
      nft.setApprovalForAll(address(mostar), true);
      cheats.stopPrank();
    }

    function _setInitializer() private {
      cheats.prank(owner);
      mostar.setInitializer(initializer);
    }

    function testSetInitializer() public {
      assertTrue(mostar.owner() == owner);
      assertTrue(mostar.initializer() == owner);

      // Can't set if not owner
      cheats.expectRevert(NotOwner.selector);
      mostar.setInitializer(initializer);
      
      // Can set initializer
      _setInitializer();

      assertTrue(mostar.initializer() == initializer);
    }

    function _initialize() private {
      cheats.prank(initializer);
      mostar.initialize721(nft, L2TOKEN);
    }

    function testInitialize() public {
      _setInitializer();

      // Can't initialize if no role
      cheats.expectRevert(NotInitializer.selector);
      cheats.prank(owner);
      mostar.initialize721(nft, L2TOKEN);

      uint256[] memory expectPayload = new uint256[](3);
      expectPayload[0] = DUMMY_NFT_STR;
      expectPayload[1] = DNFT_STR;
      expectPayload[2] = uint256(uint160(address(nft)));

      // Can initialize
      cheats.expectEmit(false, false, false, true);
      emit SendMsg(L2TOKEN, INITIALIZE_SELECTOR, expectPayload);
      _initialize();
    }

    function _register() private {
      cheats.prank(user1);
      mostar.send721ToL2(nft, L2USER, 0);
    }

    function testRegister() public {
      _setInitializer();
      _initialize();

      uint256[] memory expectPayload = new uint256[](6);
      expectPayload[0] = L2USER;
      expectPayload[1] = 0;
      expectPayload[2] = 0;
      expectPayload[3] = 2;
      expectPayload[4] = DNFT_URI_0;
      expectPayload[5] = DNFT_URI_1;

      cheats.expectEmit(false, false, false, true);
      emit SendMsg(L2TOKEN, REGISTER_SELECTOR, expectPayload);
      _register();

      assertEq(nft.balanceOf(user1), 0);
    }

    function _retrieve(address user) private {
      cheats.prank(user);
      mostar.retrieve721(nft, 0);
    }

    function testRetrieveUser1() public {
      _setInitializer();

      // Can't retrieve an unitialized token
      cheats.expectRevert(UninitializedOnL2.selector);
      _retrieve(user1);

      _initialize();
      _register();

      uint256[] memory expectPayload = new uint256[](5);
      expectPayload[0] = SEND_BACK;
      expectPayload[1] = uint256(uint160(address(nft))); // solidity.
      expectPayload[2] = 0;
      expectPayload[3] = 0;
      expectPayload[4] = uint256(uint160(user1));

      cheats.expectEmit(false, false, false, true);
      emit ConsumeMsg(L2TOKEN, expectPayload);
      _retrieve(user1);
    }

    // Fails when we expect an event for user1 but user2 tries to retrieve
    function testFailRetrieveUser1() public {
      _setInitializer();
      _initialize();
      _register();

      uint256[] memory expectPayload = new uint256[](5);
      expectPayload[0] = SEND_BACK;
      expectPayload[1] = uint256(uint160(address(nft))); // solidity.
      expectPayload[2] = 0;
      expectPayload[3] = 0;
      expectPayload[4] = uint256(uint160(user1));

      cheats.expectEmit(false, false, false, true);
      emit ConsumeMsg(L2TOKEN, expectPayload);
      _retrieve(user2);
    }

    function testRetrieveUser2() public {
      _setInitializer();
      _initialize();
      _register();

      uint256[] memory expectPayload = new uint256[](5);
      expectPayload[0] = SEND_BACK;
      expectPayload[1] = uint256(uint160(address(nft))); // solidity.
      expectPayload[2] = 0;
      expectPayload[3] = 0;
      expectPayload[4] = uint256(uint160(user2));

      cheats.expectEmit(false, false, false, true);
      emit ConsumeMsg(L2TOKEN, expectPayload);
      _retrieve(user2);
    }
}
