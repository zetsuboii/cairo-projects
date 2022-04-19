"""contract.cairo test file."""
import os

import pytest
from starkware.starknet.testing.starknet import Starknet
from utils import uint, str_to_felt

# The path to the contract source code.
CONTRACT_FILE = os.path.join("contracts", "mock", "m_ERC721m.cairo")

L1_MANAGER_MOCK = 111
L2_OWNER_MOCK = 222
TOKEN_ID = uint(3735928559)

REGISTER_SELECTOR = \
  453167574301948615256927179001098538682611778866623857597439531518333154691


@pytest.mark.asyncio
async def test_register_uri():
    """Tests if register function sets the uri as intended"""
    # Create a new Starknet class that simulates the StarkNet
    # system.
    starknet = await Starknet.empty()

    # Deploy the contract.
    contract = await starknet.deploy(
        source=CONTRACT_FILE, constructor_calldata=[L1_MANAGER_MOCK]
    )

    # Invoke increase_balance() twice.
    l1addrcall = await contract.get_l1_manager().call()
    assert l1addrcall.result == (L1_MANAGER_MOCK, ) 

    await contract.initialize(
      from_address=L1_MANAGER_MOCK,
      name=str_to_felt("Dummy NFT"),
      symbol=str_to_felt("DNFT"),
    ).invoke()

    await contract.register(
      selector=REGISTER_SELECTOR,
      cdata=[
        L1_MANAGER_MOCK,
        L2_OWNER_MOCK,
        TOKEN_ID[0],
        TOKEN_ID[1],
        2,
        str_to_felt("URI PART 1"),
        str_to_felt("URI PART 2")
      ]
    ).invoke()

    customuricall = await contract.get_custom_uri(token_id=TOKEN_ID).call()
    assert customuricall.result == (
      str_to_felt("URI PART 1"),
      str_to_felt("URI PART 2"),
      0,0,0,0,0,0,
    )

    # await contract.increase_balance(amount=10).invoke()
    # await contract.increase_balance(amount=20).invoke()
