import { expect } from "chai";
import { starknet } from "hardhat";

function toHex(str: string) {
  var result = '';
  for (var i=0; i< str.length; i++) {
    result += str.charCodeAt(i).toString(16);
  }
  return result;
}

const REGISTER_SELECTOR = 
  453167574301948615256927179001098538682611778866623857597439531518333154691n;

const L1_MANAGER = 111;
const L2_OWNER = 222;
const TOKEN_ID = { lo:420, hi:69 }

describe("Mock ERC721 Mostar", function () {
  it("Can initialize & register", async function () {
    const MockMostarL2 = await starknet.getContractFactory("m_ERC721m");
    const mostarL2 = await MockMostarL2.deploy({ "l1_manager_address": L1_MANAGER });

    const toFelt = (x: string) => BigInt('0x' + toHex(x))

    await mostarL2.invoke("initialize", {
      "from_address": 111, 
      "name": toFelt("Dummy NFT"), 
      "symbol": toFelt("DNFT")
    });

    await mostarL2.invoke("register", {
      "selector": REGISTER_SELECTOR,
      "calldata_size": 6,
      "calldata": [
        L1_MANAGER,
        L2_OWNER,
        TOKEN_ID.lo,
        TOKEN_ID.hi,
        toFelt("URI PART 1"),
        toFelt("URI PART 2")
      ]
    });

    const { balance } = await mostarL2.call("balanceOf", { "owner": L2_OWNER });
    expect(balance).to.be.eq(1);
  });
});
