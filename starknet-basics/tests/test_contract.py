"""contract.cairo test file."""
import os

import pytest
from starkware.starknet.testing.starknet import Starknet

# The path to the contract source code.
CONTRACT_FILE = os.path.join("contracts", "contract.cairo")

async def contract_factory():
    starknet = await Starknet.empty()
    contract = await starknet.deploy(CONTRACT_FILE)
    return starknet, contract

# The testing library uses python's asyncio. So the following
# decorator and the ``async`` keyword are needed.
@pytest.mark.asyncio
async def test_increase_balance():
    starknet, contract = await contract_factory()

    # Invoke increase_balance() twice.
    await contract.increase_balance().invoke()
    await contract.increase_balance().invoke()

    # Check the result of get_balance().
    execution_info = await contract.get_balance().call()
    assert execution_info.result == (2,)
