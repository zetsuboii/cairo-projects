import os
import pytest
from starkware.starknet.testing.starknet import Starknet

async def contract_factory(file):
    starknet = await Starknet.empty()
    contract = await starknet.deploy(file)
    return starknet, contract

CONTRACT_FILE = os.path.join('contracts', 'currency.cairo')

@pytest.mark.asyncio
async def test_balance():
  _starknet, contract = await contract_factory(CONTRACT_FILE)

  USR_ALICE = 444
  USR_BOB = 555

  await contract.register_currency(USR_ALICE, -10).invoke()
  exec_info = await contract.check_wallet(USR_ALICE).call()
  assert exec_info.result == (-10,)